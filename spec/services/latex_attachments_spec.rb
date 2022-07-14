require 'rails_helper'

class DummyLatexAttachments
  include LatexAttachments
end

RSpec.describe LatexAttachments do
  let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }
  let!(:proposal) { create(:proposal) }
  let(:person) { create(:person, :with_proposals) }
  let(:review) { create(:review, proposal_id: proposal.id, person_id: person.id) }

  describe 'add_proposal_attachments' do
    context 'with proposal files' do
      include Rack::Test::Methods
      include ActionDispatch::TestProcess::FixtureFile
      before do
        proposal.files.attach(file)
      end
      it 'with one file attached' do
        file_errors = []
        latex = DummyLatexAttachments.new
        expect(latex.add_proposal_attachments(proposal, 'test', file_errors)).not_to be_blank
      end
    end

    context 'with proposal files' do
      include Rack::Test::Methods
      include ActionDispatch::TestProcess::FixtureFile
      before do
        proposal.files.attach(nil)
      end
      it 'with no file attached' do
        file_errors = []
        latex = DummyLatexAttachments.new
        expect(latex.add_proposal_attachments(proposal, 'test', file_errors)).not_to be_blank
      end
    end
  end

  describe 'pdf_version?' do
    it 'pdf_version?' do
      latex = DummyLatexAttachments.new
      expect(latex.pdf_version?('pdf', 'pdf')).not_to be_blank
    end
  end

  describe 'write_attachment_file' do
    it 'write_attachment_file' do
      latex = DummyLatexAttachments.new
      expect(latex.write_attachment_file('test', 'pdf', nil)).not_to be_blank
    end
  end

  describe 'add_review_attachments' do
    context 'with text file' do
      include Rack::Test::Methods
      include ActionDispatch::TestProcess::FixtureFile

      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/review.text')) }
      before do
        review.files.attach(file)
      end
      it 'with one file attached' do
        file_errors = []
        latex = DummyLatexAttachments.new
        expect(latex.add_review_attachments(review, 'test', proposal, file_errors)).not_to be_blank
      end
    end

    context 'with pdf file' do
      include Rack::Test::Methods
      include ActionDispatch::TestProcess::FixtureFile
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/proposal_booklet.pdf')) }
      before do
        review.files.attach(file)
      end
      it 'with one file attached' do
        file_errors = []
        latex = DummyLatexAttachments.new
        expect(latex.add_review_attachments(review, 'test', proposal, file_errors)).not_to be_blank
      end
    end

    context 'with xlsx file' do
      include Rack::Test::Methods
      include ActionDispatch::TestProcess::FixtureFile
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/review_sample.xlsx')) }
      before do
        review.files.attach(file)
      end
      it 'with one file attached' do
        file_errors = []
        latex = DummyLatexAttachments.new
        expect(latex.add_review_attachments(review, 'test', proposal, file_errors)).not_to be_blank
      end
    end
  end
end
