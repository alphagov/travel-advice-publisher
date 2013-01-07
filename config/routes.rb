TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    resources :countries
    resources :travel_advice 
    root :to => "countries#index"
  end

  root :to => redirect('/admin')

end
