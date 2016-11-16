Rails.application.routes.draw do
  namespace :admin do
    resources :countries, only: [:index, :show] do
      resources :editions, only: [:create]
    end

    resources :editions, only: [:edit, :update, :destroy] do
      get 'diff/:compare_id', action: :diff, as: :diff, on: :member
      get 'historical_edition'
    end

    root to: "countries#index"
  end

  root to: redirect('/admin')

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
