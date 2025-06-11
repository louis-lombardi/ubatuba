Rails.application.routes.draw do
  match '*all', controller: 'application', action: 'cors_preflight_check', via: [:options]
  post  'leads', to: 'leads#create'
  get  'packages', to: 'packages#index'
  post 'ia_message', to: 'gpt#send_gpt'
  post 'whatsapp_inbond', to: 'gpt2#receive_whats'
end