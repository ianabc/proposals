require 'rails_helper'

RSpec.describe ProposalFormsHelper, type: :helper do
  describe "#proposal_form_statuses" do
    let(:proposal_form) { create(:proposal_form) }

    it "returns subjects area [title, id]" do
      proposal_form
      expect(proposal_form_statuses).to eq([%w[Draft draft], %w[Active active], %w[Inactive inactive]])
    end
  end

  describe "#proposal_type_name" do
    let(:proposal_type) { create(:proposal_type) }

    it 'returns name of proposal_type' do
      expect(proposal_type_name(proposal_type.id)).to eq(proposal_type.name)
    end
  end
end
