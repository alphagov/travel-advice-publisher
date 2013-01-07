TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    resources :countries
    resources :editions, :only => [:edit, :update]

    root :to => "countries#index"
  end

  root :to => redirect('/admin')

end
