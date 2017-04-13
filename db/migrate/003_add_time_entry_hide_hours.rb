class AddTimeEntryHideHours < ActiveRecord::Migration
  def up

    add_column :enumerations, :akquinet_hide_hours, :boolean, {:null => false, :default => false}

  end

  def down

    remove_columns :enumerations, :akquinet_hide_hours

  end
end
