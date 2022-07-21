require 'rails_helper'

RSpec.describe 'ExtractPreamblesService' do
  describe '#proposal_preambles' do
    context 'when preamble is not present' do
      before do
        @proposals = create_list(:proposal, 3, :with_organizers)

        @efs = ExtractPreamblesService.new(@proposals)
      end
      it 'no preamble' do
        expect(@efs.proposal_preambles).to eq("")
      end
    end

    context 'when preamble is present' do
      before do
        @proposals = create_list(:proposal, 3, :with_organizers, preamble: "{usepackage} {test}")

        @efs = ExtractPreamblesService.new(@proposals)
      end
      it '@preamble is userpackage and test' do
        expect(@efs.proposal_preambles).to eq("{usepackage} {test}\n\n")
      end
    end

    context 'when preamble is present' do
      before do
        @proposals = create_list(:proposal, 3, :with_organizers, preamble: 'usepackage')

        @efs = ExtractPreamblesService.new(@proposals)
      end
      it '@preamble is userpackage' do
        expect(@efs.proposal_preambles).to eq("usepackage\n\n")
      end
    end

    context 'when preamble other then userpackage' do
      before do
        @proposals = create_list(:proposal, 3, :with_organizers, preamble: 'test')

        @efs = ExtractPreamblesService.new(@proposals)
      end
      it '@preamble is test' do
        expect(@efs.proposal_preambles).to eq("")
      end
    end

    context 'when preamble starting with %' do
      before do
        @proposals = create_list(:proposal, 3, :with_organizers, preamble: '%test')

        @efs = ExtractPreamblesService.new(@proposals)
      end
      it '@preamble starting with %' do
        expect(@efs.proposal_preambles).to eq("%test\n\n")
      end
    end
  end
end
