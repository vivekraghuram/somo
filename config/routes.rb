Rails.application.routes.draw do
  root to: 'pages#home'

  resources :forms, only: [:new, :create, :destroy] do
    get 'twilio', to: 'forms#twilio'
    post 'recieve', to: 'forms#recieve'
    post 'start', to: 'forms#start'
    post 'update', to: 'forms#update'
  end

  #get 'forms/create_dev', to: 'forms#create_dev'

  #resources :twilio do
    #post 'recieve', to: 'twilio#recieve'
    #post 'start', to: 'twilio#start'

    #get 'drive', to: 'twilio#drive_save'
    #get 'send_twilio' => 'application#send_twilio'
  #end
end
