Rails.application.routes.draw do
  root to: 'pages#home'

  resources :forms, only: [:new, :create] do
    get 'twilio', to: 'forms#twilio'
  end

  get 'forms/create_dev', to: 'forms#create_dev'

  post '/twilio/recieve' => 'twilio#recieve'
  post '/twilio/start' => 'twilio#start'

  #resources :twilio do
    #post 'recieve', to: 'twilio#recieve'
    #post 'start', to: 'twilio#start'

    #get 'drive', to: 'twilio#drive_save'
    #get 'drive/start', to: 'twilio#drive_init'

    #get 'send_twilio' => 'application#send_twilio'
  #end
end
