class Answer < ApplicationRecord
  belongs_to :proposal_field
  belongs_to :proposal
  has_one_attached :file
  include Logable

  default_scope { order(version: :desc) }
  before_save :strip_whitespace
  after_commit :log_activity

  private

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?(:strip)
    end
  end

  def log_activity
    return if previous_changes.empty? or User.current.nil?

    audit!(user: User.current)
  end
end
