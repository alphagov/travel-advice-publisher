Rails.application.routes.draw do
  namespace :admin do
    resources :countries, only: %i[index show] do
      resources :editions, only: [:create] do
        resources :parts, only: %i[new create edit update show destroy] do
          get "review", on: :member
          get "confirm_destroy", on: :member
        end
      end
    end

    resources :editions, only: %i[edit update destroy] do
      get "diff/:compare_id", action: :diff, as: :diff, on: :member
      get "historical_edition"
      get "review", on: :member
      get "manage_part_ordering", on: :member
      patch "update_part_ordering", on: :member
    end

    root to: "countries#index"
  end

  resources :link_check_reports, only: %i[create show]

  post "/link-checker-api-callback" => "link_checker_api#callback", as: "link_checker_api_callback"

  root to: redirect("/admin")

  mount GovukAdminTemplate::Engine, at: "/style-guide"

  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response(
    GovukHealthcheck::SidekiqRedis,
    GovukHealthcheck::Mongoid,
  )

  get "/healthcheck/recently-published-editions" => "healthcheck#recently_published_editions"
end
