require 'rails_helper'

RSpec.describe SchedulesHelper, type: :helper do
  describe "#weeks_in_location" do
    let(:location1) { create(:location, start_date: "") }
    before do
      program_year = Date.current.year + 2
      @start_date = Date.parse("#{program_year}-06-01").next_occurring(:sunday)
      @end_date = Date.parse("#{program_year}-12-08").next_occurring(:friday)
    end
    let(:location) { create(:location, start_date: @start_date, end_date: @end_date, exclude_dates: "") }

    it "returns week if exclude_dates are empty" do
      location
      expect(weeks_in_location(location)).to eq(27)
    end

    it "returns empty string" do
      location1
      expect(weeks_in_location(location1)).to eq("")
    end
  end

  describe "#location_exclude_dates" do
    before do
      program_year = Date.current.year + 2
      @start_date = Date.parse("#{program_year}-06-01").next_occurring(:sunday)
      @end_date = Date.parse("#{program_year}-12-08").next_occurring(:friday)
      date = @start_date + 7.days
      @exclude_dates = []
      @exclude_dates << "#{date} - #{date + 5.days}"
    end
    let(:location) { create(:location, start_date: @start_date, end_date: @end_date, exclude_dates: @exclude_dates) }

    it "returns week if exclude_dates are present" do
      location
      expect(location_exclude_dates(location, 27)).to eq(26)
    end
  end

  describe "#schedule_proposal" do
    let(:proposal) { create(:proposal, code: "23wt32") }
    let(:schedule_run) { create(:schedule_run) }
    let(:schedule1) { create(:schedule, proposal: "23wt32", schedule_run_id: schedule_run.id)}
    let(:schedule2) { create(:schedule, proposal: "214t3e", schedule_run_id: schedule_run.id)}
    let(:schedule) { create(:schedule, proposal: "", schedule_run_id: schedule_run.id)}
    let(:proposal1) { create(:proposal, code: "") }

    it "returns proposal [code,title] if it has code" do
      proposal
      schedule1
      expect(schedule_proposal(schedule1.proposal)).to eq("[#{proposal.code}] #{proposal.title}")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal1
      schedule
      expect(schedule_proposal(schedule.proposal)).to eq("")
    end

    it "returns no proposal [code,title] if it has no code" do
      proposal
      schedule2
      expect(schedule_proposal(schedule2.proposal)).to eq("")
    end
  end
end
