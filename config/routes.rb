Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'application#home'

  get 'create' => 'application#create'
  get 'create_dev' => 'application#create_dev'

  get '/forms/:id/twilio' , to: 'forms#twilio'
  post '/forms/create', to: 'forms#create'
end
