Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'application#home'

  get 'create' => 'application#create'
  get 'send_twilio' => 'application#send_twilio'
  get 'create_dev' => 'application#create_dev'

  post '/forms/create', to: 'forms#create'
end
