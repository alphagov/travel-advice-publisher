Rails.application.routes.draw do
  get "/healthcheck", to: proc { [200, {}, ["OK"]] }

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

  resources :link_check_reports, only: [:create, :show]

  post "/link-checker-api-callback" => "link_checker_api#callback", as: "link_checker_api_callback"

  root to: redirect('/admin')

  mount GovukAdminTemplate::Engine, at: "/style-guide"
end
