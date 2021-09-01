class AddFormDataToPeople < ActiveRecord::Migration[6.1]
  def change
  	change_table :people, bulk: true do |t|
  		t.string :department
  		t.string :title
  		t.string :academic_status
  		t.string :country
  		t.string :province
  		t.string :state
  		t.string :city
  		t.string :street_1
  		t.string :street_2
  		t.string :year_first_phd
      t.string :address
  	end
  end
end
