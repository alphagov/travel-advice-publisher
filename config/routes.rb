TravelAdvicePublisher::Application.routes.draw do

  namespace :admin do
    resources :countries, :only => [:index, :show] do
      resources :editions, :only => [:create]
    end
    resources :editions, :only => [:edit, :update]

    match "editions/:id/publish" => "editions#publish", :as => :editions_publish, :via => :put
    match "editions/:id/archive" => "editions#archive", :as => :editions_archive, :via => :put
    
    root :to => "countries#index"
  end

  root :to => redirect('/admin')

end
