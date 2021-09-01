class RemoveOptionField < ActiveRecord::Migration[6.1]
  def change
    remove_column :proposal_fields_single_choices, :options, :jsonb
    remove_column :proposal_fields_multi_choices, :options, :jsonb
    remove_column :proposal_fields_radios, :options, :jsonb
  end
end
