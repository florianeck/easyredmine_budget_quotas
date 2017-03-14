class AddEbqSettingsToProject < ActiveRecord::Migration

  def change
    add_column :projects, :budget_quotas_money_rate_type, :string, default: 'internal'
    add_column :projects, :budget_quotas_tolerance_amount, :integer, default: 1
  end

end