namespace :birs do
  task default: 'birs:new_email_templates'

  desc "Add new BIRS Email Templates to database"
  task new_email_templates: :environment do
    organizer_invitation = { title: "Invitation email for organizer",
                             subject: "BIRS Proposal: Invite for Supporting Organizer",
                             body: '
                              <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station.</p>
                              <p>If this proposal is successful, its proposed event would be some time during the 2023 calendar year.</p>
                              <p>This invitation is intended to gauge your interest in being a supporting organizer in this proposed workshop, if it were to be accepted. A positive response to the invitation does not confirm participation, but indicates your appreciation of the scientific content of the program.</p>
                              <p>This preliminary invitation is a required step in the proposal process. Your response would help the proposal organizers and proposal reviewers determine the appeal of this proposed workshop to the wider mathematical community.</p>
                              <p>To respond to this informal invitation, please indicate your interest in this proposal by following this link by invite_deadline_date:</p>
                              <p>invite_url</p>
                              <p>If you indicate a positive response (<i>Yes</i> or <i>Maybe</i>), you will also be asked to fill out a Diversity and Inclusion survey. This survey is mandatory, but it should only take a minute to fill out, and for all questions, you are welcome to select <b>Prefer not to answer</b>. Data collected through this survey is anonymous and non-identifying. It will help organizers ensure a balanced composition of the participant pool and showcase the diversity and inclusivity of the proposed program to the review committee.</p>
                              <p>Thank you for indicating your interest in this proposed workshop!</p>
                              <p>Banff International Research Station,<br>
                                and the organizing committee.</p>',
                             email_type: "organizer_invitation_type" }

    participant_invitation = { title: "Invitation email for participant",
                               subject: "BIRS Proposal: Invite for Participant",
                               body: '
                                <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station.</p>
                                <p>If this proposal is successful, its proposed event would be some time during the 2023 calendar year.</p>
                                <p>This invitation is intended to gauge your interest in being a participant in this proposed workshop, if it were to be accepted. A positive response to the invitation does not confirm participation, but indicates your appreciation of the scientific content of the program.</p>
                                <p>This preliminary invitation is a required step in the proposal process. Your response would help the proposal organizers and proposal reviewers determine the appeal of this proposed workshop to the wider mathematical community.</p>
                                <p>To respond to this informal invitation, please indicate your interest in this proposal by following this link by invite_deadline_date:</p>
                                <p>invite_url</p>
                                <p>If you indicate a positive response (<i>Yes</i> or <i>Maybe</i>), you will also be asked to fill out a Diversity and Inclusion survey. This survey is mandatory, but it should only take a minute to fill out, and for all questions, you are welcome to select <b>Prefer not to answer</b>. Data collected through this survey is anonymous and non-identifying. It will help organizers ensure a balanced composition of the participant pool and showcase the diversity and inclusivity of the proposed program to the review committee.</p>
                                <p>Thank you for indicating your interest in this proposed workshop!</p>
                                <p>Banff International Research Station,<br>
                                  and the organizing committee.</p>',
                               email_type: "participant_invitation_type" }

    organizer = EmailTemplate.create(title: organizer_invitation[:title], subject: organizer_invitation[:subject],
                                     body: organizer_invitation[:body], email_type: organizer_invitation[:email_type])
    participant = EmailTemplate.create(title: participant_invitation[:title],
                                       subject: participant_invitation[:subject], body: participant_invitation[:body], email_type: participant_invitation[:email_type])
  end
end
