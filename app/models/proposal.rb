class Proposal < ApplicationRecord
  include AASM
  include PgSearch::Model
  include Logable

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
  has_many :reviews, dependent: :destroy
  has_many :proposal_versions, dependent: :destroy

  before_save :strip_whitespace
  before_save :create_code, if: :is_submission
  after_commit :log_activity

  validates :year, :title, presence: true, if: :is_submission
  validate :subjects, if: :is_submission
  validate :minimum_organizers, if: :is_submission
  validate :preferred_locations, if: :is_submission
  validate :not_before_opening, if: :is_submission
  validate :cover_letter_field, if: :is_submission

  pg_search_scope :search_proposals, against: %i[title code],
                                     associated_against: {
                                       people: %i[firstname lastname]
                                     }, using: {
                                       tsearch: {
                                         prefix: true
                                       }
                                     }

  pg_search_scope :search_proposal_type, against: %i[proposal_type_id]
  pg_search_scope :search_proposal_status, against: %i[status]
  pg_search_scope :search_proposal_year, against: %i[year]

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
    declined: 9,
    revision_requested_spc: 10,
    revision_submitted_spc: 11,
    in_progress_spc: 12,
    shortlisted: 13
  }

  aasm column: :status, enum: true do
    state :draft, initial: true
    state :submitted
    state :initial_review
    state :revision_requested
    state :revision_requested_spc
    state :revision_submitted
    state :revision_submitted_spc
    state :in_progress
    state :in_progress_spc
    state :decision_pending
    state :decision_email_sent
    state :shortlisted

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
      transitions from: %i[in_progress revision_submitted revision_submitted_spc], to: :decision_pending
    end

    event :requested do
      transitions from: %i[initial_review decision_pending revision_submitted], to: :revision_requested
    end

    event :requested_spc do
      transitions from: %i[initial_review decision_pending revision_submitted_spc shortlisted],
                  to: :revision_requested_spc
    end

    event :revision do
      transitions from: :revision_requested, to: :revision_submitted
    end

    event :revision_spc do
      transitions from: :revision_requested_spc, to: :revision_submitted_spc
    end

    event :decision do
      transitions from: %i[decision_pending shortlisted], to: :decision_email_sent
    end
    event :progress_spc do
      transitions from: :revision_submitted_spc, to: :in_progress_spc
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
    draft? || revision_requested? || revision_requested_spc?
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

  def self.to_csv(proposals)
    CSV.generate(headers: true) do |csv|
      csv << HEADERS
      proposals.find_each do |proposal|
        csv << each_row(proposal)
      end
    end
  end

  HEADERS = ["Code", "Proposal Title", "Proposal Type", "Preffered Locations", "Status",
             "Updated", "Subject Area", "Lead Organizer", "Supporting Organizers"].freeze

  def self.each_row(proposal)
    [proposal&.code, proposal&.title, proposal&.proposal_type&.name,
     proposal&.the_locations, proposal&.status, proposal&.updated_at&.to_date,
     proposal.subject&.title, proposal&.lead_organizer&.fullname,
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
    return if draft? || revision_requested? || revision_requested_spc? || allow_late_submission

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

  def cover_letter_field
    return unless revision_requested_spc?

    errors.add('Cover Letter:', "shouldn't be empty.") if cover_letter.blank?
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

  def log_activity
    return if previous_changes.empty? || User.current.nil?

    audit!(user: User.current)
  end
end
