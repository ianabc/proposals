require 'rails_helper'

RSpec.describe Schedule, type: :model do
  describe 'validations' do
    it 'has valid factory' do
      expect(build(:schedule)).to be_valid
    end

    it 'requires a case_num' do
      p = build(:schedule, case_num: '')
      expect(p.valid?).to be_falsey
    end

    it 'requires a week' do
      p = build(:schedule, week: '')
      expect(p.valid?).to be_falsey
    end

    it "requires an hmc_score" do
      p = build(:schedule, hmc_score: '')
      expect(p.valid?).to be_falsey
    end

    it "has a schedule_run_id" do
      p = build(:schedule, schedule_run_id: '')
      expect(p.valid?).to be_falsey
    end
  end

  describe 'associations' do
    it { should belong_to(:schedule_run) }
  end

  describe '#choice' do
    context "when proposal or assigned_date is empty" do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: "23wetdf45") }

      it 'returns empty string' do
        expect(schedule.choice).to eq("")
      end
    end

    context "when proposal preferred_dates are empty" do
      let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20") }
      let(:schedule_run) { create(:schedule_run) }
      let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id) }

      it 'returns empty string' do
        expect(schedule.choice).to eq("")
      end
    end
  end

  describe '#top_score' do
    let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: proposal) }
    it 'expecting response accordingly' do
      expect(schedule.top_score).to be_present
    end
  end

  describe '#dates' do
    let(:proposal) { create(:proposal, assigned_date: "2023-01-15 - 2023-01-20", code: "23wt4ed") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule) { create(:schedule, schedule_run_id: schedule_run.id, proposal: proposal) }
    it 'if schedule run location week is not zero ' do
      expect(schedule.dates).to be_present
    end
  end
end
