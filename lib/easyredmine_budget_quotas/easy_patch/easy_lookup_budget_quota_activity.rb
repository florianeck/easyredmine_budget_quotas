require 'easy_extensions/easy_lookups/easy_lookup'

module EasyPatch
  class EasyLookupBudgetQuotaActivity < EasyExtensions::EasyLookups::EasyLookup

    def attributes
      [
        [l(:field_name), 'name']
      ].concat(super)
    end
    
    def entity_name
      "TimeEntryActivity"
    end

  end
end
