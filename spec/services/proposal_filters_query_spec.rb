require 'rails_helper'

RSpec.describe 'ProposalFiltersQuery' do
  before do
    @proposals = Proposal.order(:code, :created_at)

    @efs = ProposalFiltersQuery.new(@proposals)
  end

  describe '#filter_by_keyword' do
    it 'keyword present' do
      response = @efs.filter_by_keyword('test')
      expect(response.count).to eq(0)
    end

    it 'with no keyword' do
      response = @efs.filter_by_keyword(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_workshop_year' do
    it 'year present' do
      response = @efs.filter_by_workshop_year('test')
      expect(response.count).to eq(0)
    end

    it 'with no year' do
      response = @efs.filter_by_workshop_year(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_subject_area' do
    it 'subject_area present' do
      response = @efs.filter_by_subject_area(['test'])
      expect(response.count).to eq(0)
    end

    it 'with blank subject_area' do
      response = @efs.filter_by_subject_area([])
      expect(response.count).to eq(0)
    end

    it 'with no subject_area' do
      response = @efs.filter_by_subject_area(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_proposal_type' do
    it 'proposal_type present' do
      response = @efs.filter_by_proposal_type('test')
      expect(response.count).to eq(0)
    end

    it 'with no proposal_type' do
      response = @efs.filter_by_proposal_type(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_status' do
    it 'status present' do
      response = @efs.filter_by_status(%w[test test2])
      expect(response.count).to eq(0)
    end

    it 'with no status' do
      response = @efs.filter_by_status(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_location' do
    it 'location present' do
      response = @efs.filter_by_location('test')
      expect(response.count).to eq(0)
    end

    it 'with no location' do
      response = @efs.filter_by_location(nil)
      expect(response.count).to eq(0)
    end
  end

  describe '#filter_by_outcome' do
    it 'outcome present' do
      response = @efs.filter_by_outcome('test')
      expect(response.count).to eq(0)
    end

    it 'with no outcome' do
      response = @efs.filter_by_outcome(nil)
      expect(response.count).to eq(0)
    end
  end
end
