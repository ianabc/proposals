namespace :birs do
  task default: 'birs:proposal_versions'

  desc "Add proposal versions of submitted proposals"
  task proposal_versions: :environment do
    proposals = Proposal.where.not(status: 'draft')
    proposals.find_each do |proposal|
      ProposalVersion.find_or_create_by(title: proposal&.title, year: proposal&.year,
                                        proposal_id: proposal.id, subject: proposal&.subject&.id,
                                        ams_subject_one: proposal&.ams_subjects&.first&.id,
                                        ams_subject_two: proposal&.ams_subjects&.last&.id)
    end
  end
end
