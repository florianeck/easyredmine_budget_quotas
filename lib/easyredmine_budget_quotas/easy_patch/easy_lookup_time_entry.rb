require 'easy_extensions/easy_lookups/easy_lookup'

module EasyPatch
  class EasyLookupTimeEntry < EasyExtensions::EasyLookups::EasyLookup

    def attributes
      [
        [l(:field_name), 'name']
      ].concat(super)
    end
    
    def entity_name
      "BudgetQuotaTimeEntry"
    end

  end
end
