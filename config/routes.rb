TravelAdvicePublisher::Application.routes.draw do
  namespace :admin do
    resources :countries, :only => [:edit, :index, :show, :update] do
      resources :editions, :only => [:create]
    end

    resources :editions, :only => [:edit, :update, :destroy] do
      get 'diff/:compare_id', :to => :diff, :as => :diff, :on => :member
    end

    root :to => "countries#index"
  end

  root :to => redirect('/admin')

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
