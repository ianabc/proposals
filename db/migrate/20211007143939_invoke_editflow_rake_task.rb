class InvokeEditflowRakeTask < ActiveRecord::Migration[6.1]
  def change
    Rake::Task['birs:editflow_id'].invoke
  end
end
