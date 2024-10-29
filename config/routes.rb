Rails.application.routes.draw do
  post  'leads', to: 'leads#create'
  get  'packages', to: 'packages#index'
end
