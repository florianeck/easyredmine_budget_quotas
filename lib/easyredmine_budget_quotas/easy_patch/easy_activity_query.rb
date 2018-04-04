class EasyActivityQuery < EasyQuery

  def available_filters
    {}
  end

  def available_columns
    [ EasyQueryColumn.new(:name) ]
  end

  def default_list_columns
    ['name']
  end

  def searchable_columns
    []
  end

  def entity
    TimeEntryActivity
  end

end
