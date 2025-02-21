Rails.application.routes.draw do
  namespace :admin do
    resources :countries, only: %i[index show] do
      resources :editions, only: [:create]
    end

    resources :editions, only: %i[edit update destroy] do
      get "diff/:compare_id", action: :diff, as: :diff, on: :member
      get "historical_edition"
      resources :schedulings, only: %i[new create] do
        delete "cancel", to: "schedulings#destroy", on: :collection
      end
    end

    root to: "countries#index"
  end

  resources :link_check_reports, only: %i[create show]

  post "/link-checker-api-callback" => "link_checker_api#callback", as: "link_checker_api_callback"

  root to: redirect("/admin")

  mount GovukPublishingComponents::Engine, at: "/component-guide"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::SidekiqRedis,
    GovukHealthcheck::Mongoid,
  )
end
