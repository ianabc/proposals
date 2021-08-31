class UpdateDemographicDataTable < ActiveRecord::Migration[6.1]
  def change
    DemographicData.all.each do |data|
      result = data.result
      result["citizenships"] = 'Prefer not to answer' if result["citizenships"].first.blank?
      result["indigenous_person"] = 'Prefer not to answer' if result["indigenous_person"].blank?
      if result["indigenous_person"] == 'Yes' && result["indigenous_person_yes"].first.blank?
        result["indigenous_person_yes"] = 'Prefer not to answer'
      end
      result["ethnicity"] = 'Prefer not to answer' if result["ethnicity"].first.blank?
      result["gender"] = 'Prefer not to answer' if result["gender"].blank?
      result["community"] = 'Prefer not to answer' if result["community"].blank?
      result["disability"] = 'Prefer not to answer' if result["disability"].blank?
      result["minorities"] = 'Prefer not to answer' if result["minorities"].blank?
      result["stem"] = 'Prefer not to answer' if result["stem"].blank?
      result["underRepresented"] = 'Prefer not to answer' if result["underRepresented"].blank?
      data.save
    end
  end
end
