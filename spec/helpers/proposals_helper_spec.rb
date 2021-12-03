require 'rails_helper'

RSpec.describe ProposalsHelper, type: :helper do
  describe "#proposal_types" do
    let(:location) { create(:location) }
    let(:proposal_type) { create(:proposal_type, locations: [location]) }
    let(:published_form) { create(:proposal_form, proposal_type: proposal_type, status: :active) }
    let(:proposal_type1) { create(:proposal_type, locations: [location]) }
    let(:draft_form) { create(:proposal_form, proposal_type: proposal_type1, status: :draft) }

    it "returns proposal types [name,id] if it has publish form" do
      published_form
      expect(proposal_types).to eq([[proposal_type.name, proposal_type.id]])
    end

    it "returns no proposal types [name,id] if not has publish form" do
      draft_form
      expect(proposal_types).to eq([])
    end
  end

  describe "#proposal_type_year" do
    let(:proposal_type) { create(:proposal_type) }
    it "return array of year comma separated [year]" do
      expect(proposal_type_year(proposal_type)).to eq(%w[2021 2022 2023])
    end
    it "does not return array of year comma separated [year]" do
      proposal_type.update(year: "")
      expect(proposal_type_year(proposal_type)).to eq([Date.current.year + 2])
    end
  end

  describe "#locations" do
    let(:locations_list) { create_list(:location, 4) }
    it "returns array of locations [name,id]" do
      locations_list
      expect(locations).to match_array(locations_list.pluck(:name, :id))
    end
  end

  describe "#all_statuses" do
    it "returns array of statuses[status,id] " do
      expect(all_statuses).to eq(Proposal.statuses.map { |k, v| [k.humanize.capitalize, v] })
    end
  end

  describe "#all_proposal_types" do
    let(:proposal_types_list) { create_list(:proposal_type, 4) }
    it "returns array of proposal_types [name,id]" do
      proposal_types_list
      expect(all_proposal_types).to match_array(proposal_types_list.pluck(:name, :id))
    end
  end

  describe "#common_proposal_fields" do
    let(:p_type) { create(:proposal_type) }
    let(:p_form) { create(:proposal_form, proposal_type: p_type, status: :active) }
    let(:fields) { create(:proposal_field, :radio_field, proposal_form: p_form) }
    let(:proposal) { create(:proposal, proposal_form: p_form, proposal_type: p_type) }
    it "returns proposal fields" do
      fields
      expect(common_proposal_fields(proposal)).to eq([fields])
    end
  end

  describe '#proposal_ams_subjects_code' do
    let(:proposal) { create :proposal }
    let(:subject_category) { create(:subject_category) }
    let(:subject) { create(:subject, subject_category_id: subject_category.id) }
    let(:ams_subject) do
      create(:ams_subject,
             subject_category_ids: subject_category.id,
             subject_id: subject.id)
    end
    let(:proposal_ams_subject) do
      create(:proposal_ams_subject, proposal: proposal, ams_subject: ams_subject, code: 'code2')
    end

    before do
      proposal.proposal_ams_subjects << proposal_ams_subject
    end

    it 'returns id of proposal ams subject with provided code' do
      expect(proposal_ams_subjects_code(proposal, 'code2')).to eq(ams_subject.id)
    end
  end

  describe "#assigned_dates" do
    context "when start date is blank" do
      let(:location) { create(:location) }
      it "creates range of dates" do
        assigned_dates(location)
        expect(response).to have_http_status(:ok)
      end
      it "does not return range of dates" do
        assigned_dates("")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#approved_proposals" do
    let(:proposal) { create(:proposal) }
    it "creates a successful response" do
      approved_proposals(proposal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#proposal_version" do
    let(:proposal) { create(:proposal) }
    let(:version) { create(:proposal_version) }
    it "returns the version of proposal" do
      proposal_version(version, proposal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#proposal_version_title" do
    let(:proposal) { create(:proposal) }
    let(:proposal_version) { create(:proposal_version, proposal_id: proposal.id) }
    it "returns the title of proposal version" do
      proposal_version
      proposal_version_title(1, proposal)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#invite_last_name" do
    let(:person) { create(:person) }
    let(:invite) { create(:invite, person_id: person.id) }
    it "returns the last name of invite" do
      invite_last_name(invite)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#invite_first_name" do
    let(:person) { create(:person) }
    let(:invite) { create(:invite, person_id: person.id) }
    it "returns the first name of invite" do
      invite_first_name(invite)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#no_of_participants" do
    let(:proposal) { create(:proposal) }
    let(:invite) { create(:invite) }
    it "returns the last name of invite" do
      no_of_participants(invite, proposal.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#confirmed_participants" do
    let(:proposal) { create(:proposal) }
    let(:invite) { create(:invite) }
    it "returns the last name of invite" do
      confirmed_participants(invite, proposal.id)
      expect(response).to have_http_status(:ok)
    end
  end
end
