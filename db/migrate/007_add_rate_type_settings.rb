class AddRateTypeSettings < ActiveRecord::Migration

  def change
    add_column :projects, :ebq_rate_type_settings, :text
  end
end