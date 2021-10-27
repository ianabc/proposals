class Review < ApplicationRecord
  belongs_to :person
  belongs_to :proposal
  # isQuick is ture means it's EDI review otherwise scientific
  has_many_attached :files

  def file_type(file)
    file.content_type.in?(["application/pdf", "text/plain"])
  end
end
