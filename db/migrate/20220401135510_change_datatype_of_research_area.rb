class ChangeDatatypeOfResearchArea < ActiveRecord::Migration[6.1]
  def change
    change_column(:people, :research_areas, :string)
  end
end
