class RemoveHideableCf < ActiveRecord::Migration
  def change

    drop_table :akquinet_time_entry_custom_fields_activities

  end
end
