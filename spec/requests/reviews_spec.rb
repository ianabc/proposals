require 'rails_helper'

RSpec.describe "Reviews", type: :request do
  include Rack::Test::Methods
  include ActionDispatch::TestProcess::FixtureFile
  let(:person) { create(:person, :with_proposals) }
  let(:proposal) { person.proposals.first }
  let(:review) { create(:review, proposal_id: proposal.id, person_id: person.id) }

  describe "POST /add_file" do
    context 'when file content type is plain text or pdf' do
      it 'saves the uploaded file' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/files/review.text'), 'text/plain')
        expect do
          post add_file_review_url(review), file: file
        end.to change(ActiveStorage::Attachment, :count).by(1)
      end
    end

    context 'when file content type is not plain text or pdf' do
      it 'saves the uploaded file' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/files/review_sample.xlsx'))
        expect do
          post add_file_review_url(review), file: file
        end.to change(ActiveStorage::Attachment, :count).by(0)
      end
    end
  end
end
