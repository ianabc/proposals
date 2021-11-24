namespace :birs do
  desc "Add code to existing proposal types"
  task add_codes: :environment do
    type_codes = {
      '5 Day Workshop' => 'w5',
      '2 Day Workshop' => 'w2',
      'Summer School' => 'ss',
      'Focussed Research Group' => 'frg',
      'Research in Teams' => 'rit',
      'Hybrid Thematic Program' => 'htp'
    }

    ProposalType.all.each do |p|
      code = type_codes[p.name]
      p.update(code: code) if code
    end
  end
end
