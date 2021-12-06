require 'rails_helper'

RSpec.describe EmailTemplatesHelper, type: :helper do
  describe '#types_of_email' do
    let(:templates) do
      [%w[Revision revision_type], %w[Reject reject_type], %w[Approval approval_type],
       ["Decision Email", "decision_email_type"], ["Organizer Invitation", "organizer_invitation_type"],
       %w[Participant participant_invitation_type], ["Revision SPC", "revision_spc_type"]]
    end

    it 'returns email types' do
      expect(types_of_email).to eq(templates)
    end
  end

  # describe '#name_of_templates' do
  #   let(:template_name) { create(:email_template, name: '') }

  #   it 'returns name of templates' do
  #     expect(name_of_templates).to eq(template_name)
  #   end
  # end
end
