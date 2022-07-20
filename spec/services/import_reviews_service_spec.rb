require 'rails_helper'

RSpec.describe 'ImportReviewsService' do
  ENV['EDITFLOW_API_URL'] = 'http://api.fixer.io/latest?symbols=USD&base=EUR'
  let!(:proposal) { create(:proposal) }
  let!(:person) { create(:person, :with_proposals) }
  let!(:review) { create(:review, proposal_id: proposal.id, person_id: person.id) }

  before do
    stub_request(:get, "http://example.com")
      .to_return(body: '
        {
          "data": "test"
        }')
    stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
      .to_return(body: '
        {
          "data": {
            "article": {
              "reviewVersionLatest": {
            "number": 1,
            "reviews": [{
              "reviewer" : {
                "nameFull" : "test"
              },
              "isQuick": "test",
              "score" : 100,
              "reports" : [{
                "fileID" : 100,
                "dateReported" : 2022
              }]
            }]
          }
          },
          "fileURL" : {
            "url" : "http://example.com"
          }
        }

        }')

    @efs = ImportReviewsService.new(proposal)
  end

  describe '#proposal_reviews' do
    context 'when response.body has no errors' do
      let(:proposal_role) { create(:proposal_role, proposal: proposal) }
      let(:lead_organizer) { proposal_role.person }

      it 'with lead organizer' do
        proposal_role.role.update(name: 'lead_organizer')
        review.update(version: 1)
        expect(@efs.proposal_reviews).to be_a Array
      end

      it 'with no lead organizer' do
        review.update(version: 1)
        expect(@efs.proposal_reviews).to be_a Array
      end
    end
  end

  describe '#proposal_reviews' do
    context 'with response.body.errors'
    before do
      stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
        .to_return(body: '
        {
          "data": "test"
          "errors" : "errors"
        }')
    end
    it 'will return nill' do
      review.update(version: 1)
      expect(@efs.proposal_reviews).to eq(nil)
    end
  end

  context 'with no errors' do
    before do
      stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
        .to_return(body: '
        {
          "data": "test"
        }')
    end
    it 'with nil' do
      review.update(version: 1)
      expect(@efs.proposal_reviews).to eq(nil)
    end
  end

  context 'review["reports"] is nill' do
    before do
      stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
        .to_return(body: '
        {
          "data": {
            "article": {
              "reviewVersionLatest": {
            "number": 1,
            "reviews": [{
              "reviewer" : {
                "nameFull" : "test"
              },
              "isQuick": "test",
              "score" : 100

          }]
        }
      }
    }
  }')
    end
    it 'will return an Array' do
      review.update(version: 1)
      expect(@efs.proposal_reviews).to be_a Array
    end
  end

  context 'report["fileID"].blank?' do
    before do
      stub_request(:post, "http://api.fixer.io/latest?symbols=USD&base=EUR")
        .to_return(body: '
        {
          "data": {
            "article": {
              "reviewVersionLatest": {
            "number": 2,
            "reviews": [{
              "reviewer" : {
                "nameFull" : "test"
              },
              "isQuick": "test",
              "score" : 100,
              "reports" : [{
                "dateReported" : 2022
              }]

          }]
        }
      }
    }
  }')
    end
    it 'will return an Array' do
      review.update(version: 1)
      expect(@efs.proposal_reviews).to be_a Array
    end
  end
end
