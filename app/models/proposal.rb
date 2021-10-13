class Proposal < ApplicationRecord
  include AASM
  include PgSearch::Model
  pg_search_scope :search_proposals, against: %i[title code],
                                     associated_against: {
                                       people: %i[firstname lastname]
                                     }

  pg_search_scope :search_proposal_type, against: %i[proposal_type_id]
  pg_search_scope :search_proposal_status, against: %i[status]
  pg_search_scope :search_proposal_subject, against: %i[subject_id]
  pg_search_scope :search_proposal_year, against: %i[year]

  attr_accessor :is_submission, :allow_late_submission

  has_many_attached :files
  has_many :proposal_locations, dependent: :destroy
  has_many :locations, -> { order 'proposal_locations.position' },
           through: :proposal_locations
  belongs_to :proposal_type
  has_many :proposal_roles, dependent: :destroy
  has_many :people, through: :proposal_roles
  has_many(:answers, -> { order 'answers.proposal_field_id' },
           inverse_of: :proposal, dependent: :destroy)
  has_many :invites, dependent: :destroy
  belongs_to :proposal_form
  has_many :proposal_ams_subjects, dependent: :destroy
  has_many :ams_subjects, through: :proposal_ams_subjects
  belongs_to :subject, optional: true
  has_many :staff_discussions, dependent: :destroy
  has_many :emails, dependent: :destroy

  validates :year, :title, presence: true, if: :is_submission
  validate :subjects, if: :is_submission
  validate :minimum_organizers, if: :is_submission
  validate :preferred_locations, if: :is_submission
  validate :not_before_opening, if: :is_submission
  before_save :strip_whitespace
  before_save :create_code, if: :is_submission

  HEADERS = ["Code", "Proposal Title", "Proposal Type", "Lead Organizer", "Preffered Locations", "Status",
             "Updated", "BIRS Subject", "Supporting Organizers"].freeze

  enum status: {
    draft: 0,
    submitted: 1,
    initial_review: 2,
    revision_requested: 3,
    revision_submitted: 4,
    in_progress: 5,
    decision_pending: 6,
    decision_email_sent: 7,
    approved: 8,
    declined: 9
  }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :submitted
    state :initial_review
    state :revision_requested
    state :revision_submitted
    state :in_progress
    state :decision_pending
    state :decision_email_sent

    event :active do
      transitions from: :draft, to: :submitted
    end

    event :review do
      transitions from: :submitted, to: :initial_review
    end

    event :progress do
      transitions from: %i[initial_review revision_submitted], to: :in_progress
    end

    event :pending do
      transitions from: %i[in_progress revision_submitted], to: :decision_pending
    end

    event :requested do
      transitions from: %i[initial_review decision_pending revision_submitted], to: :revision_requested
    end

    event :revision do
      transitions from: :revision_requested, to: :revision_submitted
    end

    event :decision do
      transitions from: :decision_pending, to: :decision_email_sent
    end
  end

  scope :active_proposals, lambda {
    where(status: 'submitted')
  }

  scope :no_of_participants, lambda { |id, invited_as|
    joins(:invites).where('invites.invited_as = ?
      AND invites.proposal_id = ?', invited_as, id)
  }

  scope :submitted_type, lambda { |type|
    joins(:proposal_type).where(proposal_type: { name: type })
  }

  def editable?
    draft? || revision_requested?
  end

  def demographics_data
    DemographicData.where(person_id: invites.where(invited_as: 'Participant')
                   .pluck(:person_id))
  end

  def invites_demographic_data
    # persons can have multiple confirmed invites
    # for persons with more than one demo data record, use the latest one
    DemographicData.where(person_id: invites.where(status: 'confirmed')
                   .pluck(:person_id).uniq).order(:id)
                   .index_by(&:person_id).values
  end

  def create_organizer_role(person, organizer)
    proposal_roles.create!(person: person, role: organizer)
  end

  def lead_organizer
    proposal_roles.joins(:role).find_by('roles.name = ?',
                                        'lead_organizer')&.person
  end

  def the_locations
    locations.pluck(:name).join(', ')
  end

  def list_of_organizers
    invites.where(invites: { invited_as: 'Organizer', status: 'confirmed' }).map(&:person)
           .map(&:fullname).join(', ')
  end

  def supporting_organizers
    invites.where(invited_as: 'Organizer').where(response: %w[yes maybe])
  end

  def participants
    invites.where(invited_as: 'Participant').where(response: %w[yes maybe])
  end

  def participants_career(career)
    person_ids = participants.map(&:person_id)
    Person.where(id: person_ids).where(academic_status: career)
  end

  def self.supporting_organizer_fullnames(proposal)
    proposal&.supporting_organizers&.map { |org| "#{org.firstname} #{org.lastname}" }&.join(', ')
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      all.find_each do |proposal|
        csv << each_row(proposal)
      end
    end
  end

  def self.each_row(proposal)
    [proposal&.code, proposal&.title, proposal&.proposal_type&.name,
     proposal&.lead_organizer&.fullname, proposal&.the_locations,
     proposal&.status, proposal&.updated_at&.to_date, proposal.subject&.title,
     supporting_organizer_fullnames(proposal)]
  end

  def pdf_file_type(file)
    file.content_type.in?(%w[application/pdf])
  end

  def macros
    preamble || ''
  end

  def max_supporting_organizers
    proposal_type&.co_organizer
  end

  def max_participants
    proposal_type&.participant
  end

  def max_virtual_participants
    300 # temp until max_virtual setting is added
  end

  def max_total_participants
    max_participants + max_virtual_participants
  end

  private

  def not_before_opening
    return if draft? || revision_requested? || allow_late_submission
    return unless DateTime.current.to_date > proposal_type.closed_date.to_date

    errors.add("Late submission - ", "proposal submissions closed on
               #{proposal_type.closed_date.to_date}".squish)
  end

  def minimum_organizers
    return unless invites.where(status: 'confirmed').count < 1

    errors.add('Supporting Organizers: ', 'At least one supporting organizer
               must confirm their participation by following the link in the
               email that was sent to them.'.squish)
  end

  def subjects
    errors.add('Subject Area:', "please select a subject area") if subject.nil?
    errors.add('AMS Subjects:', 'please select 2 AMS Subjects') unless ams_subjects.pluck(:code).count == 2
  end

  def next_number
    codes = Proposal.submitted_type(proposal_type.name).pluck(:code)
    last_code = codes.reject { |c| c.to_s.empty? }.max

    return '001' if last_code.blank?

    (last_code[-3..].to_i + 1).to_s.rjust(3, '0')
  end

  def create_code
    return if code.present?

    tc = proposal_type.code || 'xx'
    self.code = year.to_s[-2..] + tc + next_number
  end

  def preferred_locations
    return unless locations.empty?

    errors.add('Preferred Locations:', "Please select at least one preferred
                 location".squish)
  end

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end
end
