class Answer < ApplicationRecord
  belongs_to :proposal_field
  belongs_to :proposal
  has_one_attached :file

  default_scope { order(version: :desc) }
  before_save :strip_whitespace

  private

  def strip_whitespace
    attributes.each do |key, value|
      self[key] = value.strip if value.respond_to?("strip")
    end
  end
end
