require 'rails_helper'

RSpec.describe ProposalFieldsHelper, type: :helper do
  describe "#proposal_type_locations" do
    let(:locations) { create_list(:location, 2) }
    let(:proposal_type) { create(:proposal_type, locations: locations) }

    it "returns locations of a proposal type" do
      proposal_type_locations(proposal_type).each do |location|
        loc = proposal_type.locations.where(id: location.last).first
        location_string = "#{loc.name} (#{loc.city}, #{loc.country})"
        expect(location.first).to eq(location_string)
      end
    end
  end

  describe "#proposal_field_options" do
    let(:radio_field) { create(:proposal_field, :radio_field) }
    let(:option) { create(:option, proposal_field: radio_field) }

    it "returns array of options value and text" do
      option
      expect(proposal_field_options(radio_field)).to match_array([%w[Male M]])
    end

    it 'returns empty array' do
      expect(proposal_field_options(radio_field)).to match_array([])
    end
  end

  describe "#options_for_field" do
    let(:single_choice_field) { create(:proposal_field, :single_choice_field) }
    let(:option1) { create(:option, proposal_field: single_choice_field) }
    let(:option2) { create(:option, proposal_field: single_choice_field, text: 'Female') }

    it 'returns array of option values' do
      option1
      option2
      expect(options_for_field(single_choice_field)).to match_array(%w[Female Male])
    end

    it 'returns empty array' do
      expect(options_for_field(single_choice_field)).to match_array([])
    end
  end

  describe "#multichoice_answer" do
    let(:proposal) { create(:proposal) }

    let(:field) { create(:proposal_field, :multi_choice_field) }

    let(:proposal) { create(:proposal) }
    let(:proposal) { create(:proposal) }

    let(:field) { create(:proposal_field, :multi_choice_field) }

    let(:field) { create(:proposal_field, :multi_choice_field) }

    context 'when multichoice filed has answer' do
      let(:answer) { create(:answer, proposal: proposal, proposal_field: field, answer: "[\"YES\"]") }
      it 'returns option' do
        answer
        expect(multichoice_answer(field, proposal)).to match_array('YES')
      end
    end

    context 'when multichoice filed has no answer' do
      let(:answer) { build(:answer, proposal: proposal, proposal_field: field, answer: '') }

      it 'returns nil' do
        answer
        expect(multichoice_answer(field, proposal)).to eq(nil)
      end
    end
  end

  describe '#location_in_answers' do
    let(:locations) { create_list(:location, 4) }
    let(:proposal_type) { create(:proposal_type, locations: locations) }
    let(:proposal) { create(:proposal, proposal_type: proposal_type) }

    it 'returns location ids for proposal fields' do
      expect(location_in_answers(proposal)).to match_array(proposal.locations.map(&:id))
    end
  end

  describe '#mandatory_field?' do
    let(:field) { create :proposal_field, :radio_field }
    let(:validations) { create_list(:validation, 4, proposal_field: field) }

    before do
      validations.last.update(validation_type: 'mandatory')
    end

    it 'returns true' do
      expect(mandatory_field?(field)).to include('required')
    end
  end

  describe '#location_name' do
    let(:field) { create :proposal_field, :radio_field, :location_based }
    it 'returns location detail' do
      loc = "#{field.location&.name} (#{field.location&.city}, #{field.location&.country})"
      location = "#{loc} - Based question"
      expect(location_name(field)).to eq(location)
    end
  end
end
