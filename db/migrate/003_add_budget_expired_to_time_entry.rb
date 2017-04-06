class AddBudgetExpiredToTimeEntry < ActiveRecord::Migration

  def change
    add_column :time_entries, :budget_quota_exceeded, :boolean, default: false
  end

end