require "rails_helper"

RSpec.describe ProposalMailer, type: :mailer do
  describe 'proposal_submission' do
    let(:proposal) { create(:proposal, :with_organizers) }
    let(:proposal_role) { create(:proposal_role, proposal: proposal) }
    before do
      proposal.update(status: :submitted, code: '23w501', title: 'BANFF')
      proposal_role.role.update(name: 'lead_organizer')
    end
    let(:email) { ProposalMailer.with(proposal: proposal).proposal_submission }

    it "sends an proposal_submission email" do
      expect(email.subject).to eq("BIRS Proposal #{proposal.code}: #{proposal.title}")
    end
  end

  describe 'staff_send_emails' do
    let(:proposal) { create(:proposal) }
    let(:proposal_role) { create(:proposal_role, proposal: proposal) }
    before do
      proposal.update(status: :submitted, code: '23w501', title: 'BANFF')
      proposal_role.role.update(name: 'lead_organizer')
    end
    let(:organizer) { proposal_role.person.fullname }

    context "when cc_email and bcc_email are present" do
      let(:birs_email) do
        create(:birs_email, subject: "Staff send emails",
                            cc_email: "[{\"value\":\"chris@gmail.com\"},{\"value\":\"adamvan.tuyl@gmail.com\"}]")
      end
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when cc_email is present" do
      let(:birs_email) do
        create(:birs_email, bcc_email: nil, subject: "Staff send emails",
                            cc_email: "[{\"value\":\"chris@gmail.com\"},{\"value\":\"adamvan.tuyl@gmail.com\"}]")
      end
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when bcc_email is present" do
      let(:birs_email) { create(:birs_email, cc_email: nil, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when cc_email and bcc_email are not present" do
      let(:birs_email) { create(:birs_email, cc_email: nil, bcc_email: nil, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end
  end

  describe 'new_staff_send_emails' do
    let(:proposal) { create(:proposal) }
    let(:proposal_role) { create(:proposal_role, proposal: proposal) }
    before do
      proposal.update(status: :submitted, code: '23w501', title: 'BANFF')
      proposal_role.role.update(name: 'lead_organizer')
    end
    let(:organizer) { proposal_role.person.fullname }

    context "when cc_email and bcc_email are present" do
      let(:birs_email) { create(:birs_email, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).new_staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when cc_email is present" do
      let(:birs_email) { create(:birs_email, bcc_email: nil, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).new_staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when bcc_email is present" do
      let(:birs_email) { create(:birs_email, cc_email: nil, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).new_staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end

    context "when cc_email and bcc_email are not present" do
      let(:birs_email) { create(:birs_email, cc_email: nil, bcc_email: nil, subject: "Staff send emails") }
      let(:email) { ProposalMailer.with(email_data: birs_email, organizer: organizer).new_staff_send_emails }

      it "sends email to lead_organizer & organizers" do
        expect(email.subject).to eq("Staff send emails")
      end
    end
  end
end
