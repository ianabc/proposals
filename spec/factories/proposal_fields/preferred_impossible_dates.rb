FactoryBot.define do
  factory :proposal_fields_preferred_impossible_date, class: 'ProposalFields::PreferredImpossibleDate' do
    preferred_dates_1 { '01/15/23 to 01/20/23' }
    preferred_dates_2 { '01/15/23 to 01/20/23' }
    preferred_dates_3 { '01/15/23 to 01/20/23' }
    preferred_dates_4 { '01/15/23 to 01/20/23' }
    preferred_dates_5 { '01/15/23 to 01/20/23' }
    impossible_dates_1 { '01/15/23 to 01/20/23' }
    impossible_dates_2 { '01/15/23 to 01/20/23' }
  end
end
