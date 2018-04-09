post "/budget_quotas/update_project_settings/:id" => "budget_quotas#update_project_settings", as: :update_budget_quota_project_settings

post "/budget_quotas/assign_budget_quota_to_time_entries" => "budget_quotas#assign_budget_quota_to_time_entries", as: :assign_budget_quota_to_time_entries