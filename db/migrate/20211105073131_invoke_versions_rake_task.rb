class InvokeVersionsRakeTask < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:proposal_versions'].invoke
  end
end
