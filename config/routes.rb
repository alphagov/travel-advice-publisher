Rails.application.routes.draw do
  namespace :admin do
    resources :countries, only: %i[index show] do
      resources :editions, only: [:create]
    end

    resources :editions, only: %i[edit update destroy] do
      get "diff/:compare_id", action: :diff, as: :diff, on: :member
      get "historical_edition"
    end

    root to: "countries#index"
  end

  resources :link_check_reports, only: %i[create show]

  post "/link-checker-api-callback" => "link_checker_api#callback", as: "link_checker_api_callback"

  root to: redirect("/admin")

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  get "/healthcheck", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::SidekiqRedis,
  )

  get "/healthcheck/recently-published-editions" => "healthcheck#recently_published_editions"
end
