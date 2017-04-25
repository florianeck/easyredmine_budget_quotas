Dir[File.dirname(__FILE__) + '/lib/easyredmine_budget_quotas/easy_patch/*/*/*.rb'].each {|file| require_dependency file }

ActionDispatch::Reloader.to_prepare do

  require_dependency 'easyredmine_budget_quotas/hooks'

end
