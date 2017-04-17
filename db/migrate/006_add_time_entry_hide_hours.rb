class AddTimeEntryHideHours < ActiveRecord::Migration
  def up

    unless column_exists? :enumerations, :akquinet_hide_hours
      add_column :enumerations, :akquinet_hide_hours, :boolean, {:null => false, :default => false}
    end

  end

  def down

    remove_columns :enumerations, :akquinet_hide_hours

  end
end
