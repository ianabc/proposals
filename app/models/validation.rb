class Validation < ApplicationRecord
  belongs_to :proposal_field
  enum validation_type: { mandatory: 0, 'less than (integer matcher)': 1, 'less than (float matcher)': 2,
                          'greater than (integer matcher)': 3, 'greater than (float matcher)': 4,
                          'equal (string matcher)': 5, 'equal (integer matcher)': 6, 'equal (float matcher)': 7,
                          '5-day workshop preferred/Impossible dates': 8, 'words limit': 9 }
end
