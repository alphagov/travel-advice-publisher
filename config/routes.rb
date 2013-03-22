TravelAdvicePublisher::Application.routes.draw do
  namespace :admin do
    resources :countries, :only => [:edit, :index, :show, :update] do
      resources :editions, :only => [:create]
    end

    resources :editions, :only => [:edit, :update]

    root :to => "countries#index"
  end

  root :to => redirect('/admin')
end
