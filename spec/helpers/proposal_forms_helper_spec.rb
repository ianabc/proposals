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

  describe '#validation_types' do
    let(:validations) do
      [%w[Mandatory mandatory], ["Less than (integer matcher)", "less than (integer matcher)"],
       ["Less than (float matcher)", "less than (float matcher)"],
       ["Greater than (integer matcher)", "greater than (integer matcher)"],
       ["Greater than (float matcher)", "greater than (float matcher)"],
       ["Equal (string matcher)", "equal (string matcher)"],
       ["Equal (integer matcher)", "equal (integer matcher)"], ["Equal (float matcher)", "equal (float matcher)"],
       ["5-day workshop preferred/impossible dates", "5-day workshop preferred/Impossible dates"],
       ["Words limit", "words limit"]]
    end

    it 'returns validation_types' do
      expect(validation_types).to eq(validations)
    end
  end

  describe '#proposal_forms' do
    let(:proposal_type) { create :proposal_type }
    let(:proposal_from) { create(:proposal_form, proposal_type: proposal_type, status: 'draft') }

    it 'returns active proposal forms' do
      expect(proposal_forms(proposal_type, 'draft')).to eq [proposal_from]
    end
  end
end
