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
    context "for valid parameters" do
      let(:location) { create(:location) }
      it "returns the range of dates" do
        dates = assigned_dates(location)
        expect(assigned_dates(location)).to match_array(dates)
      end
    end
    context "for invalid parameters" do
      let(:location) { create(:location, start_date: "") }
      it "does not returns the range of dates" do
        expect(assigned_dates(location)).to match_array([])
      end
    end
  end

  describe "#approved_proposals" do
    let(:proposal) { create(:proposal) }
    let(:proposals) { create_list(:proposal, 3, outcome: 'Approved') }
    it "return the code for approved proposals" do
      codes = [""] + proposals.pluck(:code)
      expect(approved_proposals(proposal)).to match_array(codes)
    end
  end

  # describe "#proposal_version" do
  #   let(:proposal) { create(:proposal) }
  #   let(:proposal_version) { create(:proposal_versionproposal_id: proposal.id) }
  #   it "returns the version of proposal" do
  #     debugger
  #     proposal_version(proposal_version, proposal)
  #     expect(response.body).to eq(proposal_version)
  #   end
  # end

  describe "#proposal_version_title" do
    let(:proposal) { create(:proposal, title: 'Test') }
    let(:proposal_version) { create(:proposal_version, proposal_id: proposal.id) }
    it "returns the title of proposal version" do
      proposal_version
      expect(proposal_version_title(1, proposal)).to eq(proposal_version.title)
    end
  end

  describe "#invite_last_name" do
    let(:person) { create(:person) }
    let(:invite) { create(:invite, person_id: person.id) }
    it "returns the last name of invite" do
      expect(invite_last_name(invite)).to eq(invite.lastname)
    end
  end

  describe "#invite_first_name" do
    let(:person) { create(:person) }
    let(:invite) { create(:invite, person_id: person.id) }
    it "returns the first name of invite" do
      expect(invite_first_name(invite)).to eq(invite.firstname)
    end
  end

  describe "#no_of_participants" do
    let(:proposal) { create(:proposal) }
    let(:invites) { create_list(:invite, 2, proposal_id: proposal.id, invited_as: "Organizer") }
    it "returns total  participants" do
      expect(no_of_participants(proposal.id, "Organizer")).to eq(invites)
    end
  end

  describe "#confirmed_participants" do
    let(:proposal) { create(:proposal) }
    let(:invites) { create_list(:invite, 2, proposal_id: proposal.id, invited_as: "Organizer", status: "confirmed") }
    it "returns confirmed participants" do
      expect(confirmed_participants(proposal.id, "Organizer")).to eq(invites)
    end
  end

  describe "#nationality_data" do
    let(:proposal) { create(:proposal) }
    it "returns the nationality" do
      expect(nationality_data(proposal)).to match_array([])
    end
  end

  describe "#ethnicity_data" do
    let(:proposal) { create(:proposal) }
    it "returns the ethnicity" do
      expect(ethnicity_data(proposal)).to match_array([])
    end
  end

  describe "#invite_deadline_date_color" do
    let(:invite) { create(:invite, status: 'pending') }
    it "it changes the color of text" do
      invite_deadline_date_color(invite)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#invite_response_color" do
    context "when status is yes or may be" do
      let(:invite) { create(:invite, response: 'yes') }
      it "changes the color of response" do
        invite_response_color(invite.response)
        expect(response).to have_http_status(:ok)
      end
    end
    context "when status is no" do
      let(:invite) { create(:invite, response: 'no') }
      it "changes the color of response" do
        invite_response_color(invite.response)
        expect(response).to have_http_status(:ok)
      end
    end
    context "when status is nil" do
      let(:invite) { create(:invite, response: nil) }
      it "changes the color of response" do
        invite_response_color(invite.response)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # describe "#career_labels" do
  #   let(:proposal) { create(:proposal) }
  #   let(:person) { create(:person, proposal_id:proposal.id) }
  #   it "returns the lables" do
  #     expect(career_labels(proposal)).to match_array([])
  #   end
  # end

  # describe "#proposal_status" do
  #   let(:proposal){ create(:proposal, status: :revision_submitted) }
  #   it "return the status of the proposal" do
  #     # status = proposal.status.split('_').map(:capitalize).join(' ')
  #     expect(proposal_status(proposal.status)).to eq("Revision Submitted")
  #   end
  # end

  # describe "#proposal_status_class" do
  #   let(:proposal){ create(:proposal, status: :revision_submitted) }
  #   it "return the status of the proposal" do
  #     expect(proposal_status_class(proposal.status)).to eq(proposal.status)
  #   end
  # end
end
