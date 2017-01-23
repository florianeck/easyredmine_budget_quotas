class AddEbqDataTypeToEnum < ActiveRecord::Migration

  def change
    add_column :enumerations, :ebq_data_type, :string
  end

end