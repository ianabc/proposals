class ProposalType < ApplicationRecord
  validates :name, :participant, :co_organizer, :code, :open_date, :closed_date, presence: true
  validates :code, uniqueness: true
  has_many :proposals, dependent: :destroy
  has_many :proposal_forms, dependent: :destroy
  has_many :proposal_type_locations, dependent: :destroy
  has_many :locations, through: :proposal_type_locations
  validate :not_closed_date_greater

  scope :active_forms, -> { joins(:proposal_forms).where('proposal_forms.status =?', 1).distinct }

  def active_form
    proposal_forms.where('proposal_forms.status =?', 1).last
  end

  def not_lead_organizer?(person_id)
    proposals.joins(proposal_roles: :role)
             .where("proposal_roles.person_id =?", person_id)
             .where('roles.name =?', 'lead_organizer').empty?
  end

  # rubocop:disable Metrics/AbcSize
  def not_closed_date_greater
    return if open_date.nil? || closed_date.nil?

    if open_date.to_date > closed_date.to_date
      errors.add("Open Date ", "#{open_date.to_date} - cannot be greater than
          Closed Date #{closed_date.to_date}".squish)
    elsif open_date.to_date == closed_date.to_date
      errors.add("Open Date ", "#{open_date.to_date} - cannot be same as
          Closed Date #{closed_date.to_date}".squish)
    end
  end
  # rubocop:enable Metrics/AbcSize
end
