module EmailAlertSignup
  class IndexPresenter
    def content_payload
      {
        base_path: base_path,
        document_type: "email_alert_signup",
        schema_name: "email_alert_signup",
        title: "Foreign travel advice",
        description: "Foreign travel advice email alert signup",
        public_updated_at: public_updated_at,
        locale: "en",
        publishing_app: "travel-advice-publisher",
        rendering_app: "email-alert-frontend",
        routes: routes,
        details: details,
        update_type: update_type,
      }
    end

    def content_id
      TravelAdvicePublisher::INDEX_EMAIL_SIGNUP_CONTENT_ID
    end

    def update_type
      "republish"
    end

  private

    def index_base_path
      "/foreign-travel-advice"
    end

    def base_path
      "#{index_base_path}/email-signup"
    end

    def public_updated_at
      Time.zone.now.iso8601
    end

    def routes
      [{ path: base_path, type: "exact" }]
    end

    def details
      {
        subscriber_list: {
          document_type: "travel_advice",
        },
        summary: summary,
        breadcrumbs: breadcrumbs,
        govdelivery_title: "Foreign travel advice",
      }
    end

    def summary
      "You'll get an email each time a country is updated."
    end

    def breadcrumbs
      [
        {
          title: "Foreign travel advice",
          link: index_base_path,
        },
      ]
    end
  end
end
