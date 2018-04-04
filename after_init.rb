Dir[File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/*/*/*.rb'].each {|file| require_dependency file }

require_dependency File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/easy_lookup_budget_quota_activity'
require_dependency File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/easy_lookup_time_entry'
require_dependency File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/easy_activity_query'
require_dependency File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/easy_budget_quota_time_entry_query'
require_dependency File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/modal_selector_controller_extension'

ActionDispatch::Reloader.to_prepare do
  require_dependency 'easyredmine_budget_quotas/hooks'
end

EasyExtensions::EasyLookups::EasyLookup.map do |easy_lookup|
  easy_lookup.register EasyPatch::EasyLookupBudgetQuotaActivity.new
  easy_lookup.register EasyPatch::EasyLookupTimeEntry.new
end

ModalSelectorsController.send :include, EasyPatch::ModelSelectorControllerExtension