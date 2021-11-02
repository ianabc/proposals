# frozen_string_literal: true

class Log < ApplicationRecord
  belongs_to :logable, polymorphic: true, optional: true
  belongs_to :user
end
