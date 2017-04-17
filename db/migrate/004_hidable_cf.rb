class HidableCf < ActiveRecord::Migration
  def up

    unless table_exists?(:akquinet_time_entry_custom_fields_activities)

      create_table :akquinet_time_entry_custom_fields_activities, :id => false do |t|

        t.column 'custom_field_id', :integer, {:null => false}
        t.column 'time_entry_activity_id', :integer, {:null => false}

      end
    end

    unless column_exists? :custom_fields, 'akquinet_extra_money_multiplied'
      add_column :custom_fields, 'akquinet_extra_money_multiplied', :boolean, {:null => false, :default => false}
    end

    unless column_exists? :custom_fields, 'akquinet_extra_money_offset'
      add_column :custom_fields, 'akquinet_extra_money_offset', :boolean, {:null => false, :default => false}
    end

  end

  def down

    drop_table :akquinet_time_entry_custom_fields_activities

    remove_column :custom_fields, 'akquinet_extra_money_multiplied'
    remove_column :custom_fields, 'akquinet_extra_money_offset'

  end
end
