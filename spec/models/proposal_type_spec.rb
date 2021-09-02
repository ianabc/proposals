require 'rails_helper'

RSpec.describe ProposalType, type: :model do
  let(:proposal_type) { create(:proposal_type) }
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:proposal_type)).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:proposals).dependent(:destroy) }
    it { should have_many(:proposal_forms).dependent(:destroy) }
    it { should have_many(:proposal_type_locations).dependent(:destroy) }
    it { should have_many(:locations).through(:proposal_type_locations) }
  end

  describe '#active_form' do
    let(:proposal_form) { create(:proposal_form, status: :active) }
    before do
      proposal_type.proposal_forms << proposal_form
    end

    it { expect(proposal_type.active_form.id).to eq(proposal_form.id) }
  end

  describe '#not_lead_organizer(person_id)' do
    let(:person) { create(:person) }

    it { expect(proposal_type.not_lead_organizer?(person.id)).to be_truthy }
  end

  describe '#not_closed_date_greater' do
    context 'when open and closed date are same' do
      before { proposal_type.update(closed_date: DateTime.now, open_date: DateTime.now) }
      it do
        expect(proposal_type.errors.full_messages).to eq(
          ["Open date  #{DateTime.now.to_date} - cannot be same as Closed Date #{DateTime.now.to_date}"]
        )
      end
    end

    context 'when open date is greater than closed date' do
      before { proposal_type.update(closed_date: DateTime.now, open_date: DateTime.now + 5.days) }
      it do
        expect(proposal_type.errors.full_messages).to eq(
          ["Open date  #{(DateTime.now + 5.days).to_date} - cannot be greater than Closed Date #{DateTime.now.to_date}"]
        )
      end
    end

    context 'when open and closed dates are nil' do
      before { proposal_type.update(closed_date: nil, open_date: nil) }
      it { expect(proposal_type).to be_invalid }
    end
  end
end
