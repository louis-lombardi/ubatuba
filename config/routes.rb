Rails.application.routes.draw do
  match '*all', controller: 'application', action: 'cors_preflight_check', via: [:options]
  post  'leads', to: 'leads#create'
  get  'packages', to: 'packages#index'
end
