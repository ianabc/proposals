# frozen_string_literal: true

module Logable
  extend ActiveSupport::Concern

  included do
    has_many :logs, as: :logable

    def audit!(user:)
      data = previous_changes
      data = data.except("updated_at")

      data = {
        logable: self,
        user: user,
        data: data
      }
      Log.create!(data)
    end
  end
end
