namespace :birs do
  task default: 'birs:new_email_templates'

  desc "Add new BIRS Email Templates to database"
  task new_email_templates: :environment do
    organizer_invitation = { title: "Invitation email for organizer",
                             subject: "BIRS Proposal: Invite for Supporting Organizer",
                             body: '
                              <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station. If successful, the program would take place at some time during the 2023 calendar year.</p>
                              <p>This invitation is intended to gauge your interest in being a supporting organizer for this proposed workshop, provided that it is accepted and that the dates work with your schedule. Your response would help the organizing committee and the BIRS review committee determine the appeal of this proposed workshop to the wider mathematical community.</p>
                              <p>Kindly indicate your response by invite_deadline_date by following the link below:</p>
                              <p>invite_url</p>
                              <p>Thank you for considering this request!</p>
                              <p>Banff International Research Station,<br>
                                and the organizing committee.</p>',
                             email_type: "organizer_invitation_type" }

    participant_invitation = { title: "Invitation email for participant",
                               subject: "BIRS Proposal: Invite for Participant",
                               body: '
                                <p>Proposal_lead_organizer_name is putting together a proposal for a proposal_type titled "proposal_title" for submission to the Banff International Research Station. If successful, the program would take place at some time during the 2023 calendar year.</p>
                                <p>This invitation is intended to gauge your interest in being a participant for this proposed workshop, provided that it is accepted and that the dates work with your schedule. Your response would help the organizing committee and the BIRS review committee determine the appeal of this proposed workshop to the wider mathematical community.</p>
                                <p>Kindly indicate your response by invite_deadline_date by following the link below:</p>
                                <p>invite_url</p>
                                <p>Thank you for considering this request!</p>
                                <p>Banff International Research Station,<br>
                                  and the organizing committee.</p>',
                               email_type: "participant_invitation_type" }

    organizer = EmailTemplate.create(title: organizer_invitation[:title], subject: organizer_invitation[:subject],
                                     body: organizer_invitation[:body], email_type: organizer_invitation[:email_type])
    participant = EmailTemplate.create(title: participant_invitation[:title],
                                       subject: participant_invitation[:subject], body: participant_invitation[:body], email_type: participant_invitation[:email_type])
  end
end
