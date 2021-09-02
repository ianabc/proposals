class Person < ApplicationRecord
  attr_accessor :is_lead_organizer, :province, :state, :skip_person_validation

  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true
  belongs_to :user, optional: true
  has_many :proposal_roles, dependent: :destroy
  has_many :proposals, through: :proposal_roles
  has_one :demographic_data, dependent: :destroy
  before_save :downcase_email

  def downcase_email
    email.downcase!
  end

  def fullname
    "#{firstname} #{lastname}"
  end

  validate :lead_organizer_attributes, if: :is_lead_organizer, on: :update
  validate :common_fields, on: :update

  def lead_organizer_attributes
    errors.add('Street 1', "can't be blank") if street_1.blank?
    errors.add('City', "can't be blank") if city.blank?
  end

  def region_type
    return "Province" if country == 'Canada'
    return "State" if country == 'United States of America'

    "Region"
  end

  def person_proposal
    proposals.where(status: "submitted")&.first
  end

  # rubocop:disable Metrics/AbcSize
  def common_fields
    return if skip_person_validation

    errors.add('Main Affiliation/Institution', "can't be blank") if affiliation.blank?
    errors.add('Department', "can't be blank") if department.blank?
    errors.add('Academic Status', "can't be blank") if academic_status.blank?
    errors.add('Year of', "PhD can't be blank") if first_phd_year.blank?
    errors.add('Country', "can't be blank") if country.blank?

    self.first_phd_year = nil if first_phd_year == "N/A"

    if academic_status == 'Other' && other_academic_status.blank?
      errors.add(:other_academic_status, "Please indicate your academic status.")
    end

    return unless country == 'Canada' || country == 'United States of America'

    # if (country == 'Canada')
    #   self.region = province if province.present?
    # elsif (country == 'United States of America')
    #   self.region = state if state.present?
    # end
    case country
    when "Canada"
      self.region = province if province.present?
    when "United States of America"
      self.region = state if state.present?
    end
    errors.add("Missing data: ", "You must select a #{region_type}") if region.blank?
  end
  # rubocop:enable Metrics/AbcSize

  def draft_proposals?
    proposals.where(status: :draft).present?
  end
end
