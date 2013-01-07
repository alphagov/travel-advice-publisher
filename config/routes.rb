TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    resources :countries
    resources :editions
    root :to => "countries#index"
  end

  root :to => redirect('/admin')

end
