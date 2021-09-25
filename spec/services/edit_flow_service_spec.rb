require 'rails_helper'

RSpec.describe 'EditFlowService' do
  let(:subject_category) { create(:subject_category) }
  let(:subject) { create(:subject, subject_category_id: subject_category.id) }
  let(:ams_subject) do
    create(:ams_subject,
           subject_category_ids: subject_category.id,
           subject_id: subject.id)
  end
  let(:proposal_ams_subject) do

  end

  before do
    @proposal = create(:proposal, :with_organizers, subject: subject)
    proposal_ams_subject = create(:proposal_ams_subject, proposal: @proposal,
                                  ams_subject: ams_subject, code: 'code2')
    @proposal.proposal_ams_subjects << proposal_ams_subject
    @EFS = EditFlowService.new(@proposal)
    update_supporting_organizers
  end

  def update_supporting_organizers
    # for some reason this info is getting blanked out with invite creation
    @proposal.invites.where(invited_as: 'Organizer').each do |invite|
      person = invite.person
      person.country = %w[Canada Mexico Brazil India Japan].sample
      person.affiliation = Faker::University.name
      person.skip_person_validation = true
      person.save!
    end
  end

  it 'has supporting organizers with countries' do
    @proposal.invites.where(invited_as: 'Organizer').each do |invite|
      expect(invite.person.country).not_to be_blank
    end
  end

  it 'accepts a proposal' do
    expect(@EFS.class).to eq(EditFlowService)
  end

  it "assigns the lead organizer's country code" do
    country = @proposal.lead_organizer.country
    code = Country.find_country_by_name(country).alpha2
    expect(@EFS.proposal_country.alpha2).to eq(code)
  end

  it ".supporting_organizers" do
    # improve me
    expect(@EFS.supporting_organizers).not_to be_empty
  end

  it ".co_authors" do
    # puts "\n\nCo_authors output:\n#{@EFS.co_authors}\n"
    expect(@EFS.co_authors).not_to be_empty
  end

  it ".query" do
    # puts "\n\nQuery output:\n#{@EFS.query}\n"
    expect(@EFS.query).not_to be_empty
  end
end
