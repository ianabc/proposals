require 'rails_helper'

RSpec.describe ScheduleRun, type: :model do
  it 'has valid factory' do
    expect(build(:schedule_run)).to be_valid
  end

  describe '#string_dates' do
    context 'When dates passed is empty' do
      let(:schedule_run) { create :schedule_run }

      it 'returns nothing' do
        expect(schedule_run.string_dates('')).to eq('')
      end
    end

    context 'When dates passed is not empty' do
      let(:schedule_run) { create :schedule_run }
      let(:dates) { ['22-03-2022', '22-03-2022', '22-03-2022', '22-03-2022'] }
      let(:output) { '22-03-2022, 22-03-2022, 22-03-2022, 22-03-2022' }

      it 'returns , seperated string of dates' do
        expect(schedule_run.string_dates(dates)).to eq(output)
      end
    end
  end

  describe '#each_schedule_row' do
    context 'When proposal is blank' do
      let(:proposal) { create :proposal}
      let(:schedule) {create :schedule}
      let(:schedule_run) {create :schedule_run}
      let(:outcome) {[schedule.week,schedule.proposal,'','']}

      it 'returns nothing' do
        expect(schedule_run.each_schedule_row(schedule,nil)).to eq(outcome)
      end
    end

    context 'When proposal is not blank' do
      let(:proposal) { create :proposal}
      let(:schedule) {create :schedule}
      let(:schedule_run) {create :schedule_run}
      let(:outcome) {[schedule.week, schedule.proposal, schedule_run.string_dates(proposal.preferred_dates),
       schedule_run.string_dates(proposal.impossible_dates)]}

      it 'returns nothing' do
        expect(schedule_run.each_schedule_row(schedule,proposal)).to eq(outcome)
      end
    end
  end

  # describe '#to_csv' do
  #   context 'Generate CSV file' do
  #     let(:schedule_run) {create :schedule_run}
  #     let(:schedule_run_id) {schedule_run.id}
  #     let(:schedule) {create :schedule}
  #     let(:case_num) {schedule.case_num}
  #     let(:csv) {Schedule.new}

  #     it 'creates CSV file with proper value' do
  #       expect(schedule_run.to_csv(1).to match_array(CSV.generate_line([
  #       schedule,proposal]))
  #     end
  #   end
  # end
end
