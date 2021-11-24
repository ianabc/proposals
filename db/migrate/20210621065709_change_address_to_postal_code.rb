class ChangeAddressToPostalCode < ActiveRecord::Migration[6.1]
  def change
    rename_column :people, :address, :postal_code
    remove_column :people, :state, :string
    rename_column :people, :province, :region
    rename_column :people, :year_first_phd, :first_phd_year
    add_column :people, :other_academic_status, :string
  end
end
