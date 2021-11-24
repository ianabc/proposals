class ChangeSiteSettingsTableName < ActiveRecord::Migration[6.1]
  def change
    rename_table :site_settings, :page_contents
  end
end
