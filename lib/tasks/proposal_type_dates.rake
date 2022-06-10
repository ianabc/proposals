namespace :birs do
  desc "set default values for no of preferred and impossible dates"
  task default_values_for_dates: :environment do

    ProposalType.all.each do |proposal_type|
      if proposal_type.max_no_of_preferred_dates == nil
        proposal_type.update_columns(max_no_of_preferred_dates: 5)
      end
      if proposal_type.min_no_of_preferred_dates == nil
        proposal_type.update_columns(min_no_of_preferred_dates: 2)
      end
      if proposal_type.max_no_of_impossible_dates == nil
        proposal_type.update_columns(max_no_of_impossible_dates: 0)
      end
      if proposal_type.min_no_of_impossible_dates == nil
        proposal_type.update_columns(min_no_of_impossible_dates: 0)
      end
    end
  end
end
