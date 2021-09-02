require 'rails_helper'

RSpec.describe Invite, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:invite)).to be_valid
    end

    it 'requires a firstname' do
      invite = build(:invite, firstname: '')
      expect(invite.valid?).to be_falsey
    end

    it 'requires a lastname' do
      invite = build(:invite, lastname: '')
      expect(invite.valid?).to be_falsey
    end

    it "requires an email" do
      invite = build(:invite, email: '')
      expect(invite.valid?).to be_falsey
    end

    it "requires an invite as" do
      invite = build(:invite, invited_as: '')
      expect(invite.valid?).to be_falsey
    end
  end

  describe 'associations' do
    it { should belong_to(:proposal) }
    it { should belong_to(:person) }
  end

  describe '#invited_as?' do
    context 'when invited as coorganizer' do
      let(:invite) { create(:invite, invited_as: "Organizer") }

      it "returns a Supporting Organizer" do
        expect(invite.invited_as?).to eq('Supporting Organizer')
      end
    end

    context 'when not invited as coorganizer' do
      let(:invite) { create(:invite, invited_as: "Not Co Organizer") }

      it "returns a Participant" do
        expect(invite.invited_as?).to eq('Participant')
      end
    end
  end

  describe '#proposal_title' do
    context 'when proposal title present' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@tes.com', invited_as: 'coorganizer')
      end
      before do
        invite.proposal.update(title: "New")
      end

      it { expect(invite.proposal.title).to eq 'New' }
    end
  end

  describe '#deadline_not_in_past' do
    context 'when deadline date is not in past' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer')
      end

      it { expect(invite.deadline_date).to be > DateTime.now }
    end

    context 'when deadline date is in past' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer')
      end
      before do
        invite.update(deadline_date: DateTime.now - 2.weeks)
      end
      it { expect(invite.errors.full_messages).to include("Deadline can't be in past") }
    end
  end

  describe '#generate_code' do
    context 'when code is not present' do
      let(:invite) do
        create(:invite, firstname: 'New', lastname: 'Proposal', email: 'test@test.com', invited_as: 'coorganizer',
                        code: nil)
      end
      it { expect(invite.code).to be_present }
    end
  end

  describe '#proposal_title' do
    let(:proposal) { create(:proposal, title: '') }
    context 'when proposal title is not present' do
      it do
        invite = Invite.new(deadline_date: DateTime.now, firstname: 'john', lastname: 'doe', email: 'john@gmail.com',
                            proposal: proposal, invited_as: 'Participant')
        invite.validate

        expect(invite.errors.full_messages).to be_present
      end
    end

    context 'when proposal title is present' do
      before { proposal.update(title: 'proposal title') }
      it do
        invite = Invite.new(deadline_date: DateTime.now, firstname: 'john', lastname: 'doe', email: 'john@gmail.com',
                            proposal: proposal, invited_as: 'Participant')
        invite.validate

        expect(invite).to be_valid
      end
    end
  end
end
