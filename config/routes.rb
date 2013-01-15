TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    resources :countries, :only => [:index, :show] do
      resources :editions, :only => [:create]
    end
    resources :editions, :only => [:edit, :update] do
      put "publish", :on => :member
    end

    root :to => "countries#index"
  end

  root :to => redirect('/admin')

end
