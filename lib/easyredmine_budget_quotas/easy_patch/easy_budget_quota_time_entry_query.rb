class EasyBudgetQuotaTimeEntryQuery < EasyQuery

  def available_filters
    return @available_filters unless @available_filters.blank?

    @available_filters = {
      'project_id' => {:type => :integer},
      'activity_id' => {:type => :integer}
    }

    @available_filters
  end

  def available_columns
    [ EasyQueryColumn.new(:activity), EasyQueryColumn.new(:comments) ]
  end

  def default_list_columns
    ['activity', 'comments']
  end

  def searchable_columns
    []
  end

  def entity
    TimeEntry
  end

end
