class HidableCf < ActiveRecord::Migration
  def up

    unless column_exists? :custom_fields, 'akquinet_extra_money_multiplied'
      add_column :custom_fields, 'akquinet_extra_money_multiplied', :boolean, {:null => false, :default => false}
    end

    unless column_exists? :custom_fields, 'akquinet_extra_money_offset'
      add_column :custom_fields, 'akquinet_extra_money_offset', :boolean, {:null => false, :default => false}
    end

  end

  def down

    remove_column :custom_fields, 'akquinet_extra_money_multiplied'
    remove_column :custom_fields, 'akquinet_extra_money_offset'

  end
end
