Rails.application.routes.draw do
  get  'lead_informations', to: 'lead_informations#index'
  get  'packages', to: 'packages#index'
end
