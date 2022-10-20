module EmailAlertSignup
  class EditionPresenter
    def initialize(edition)
      self.edition = edition
    end

    def content_payload
      {
        base_path:,
        document_type: "email_alert_signup",
        schema_name: "email_alert_signup",
        title: edition.title,
        description: "#{edition.title} Email Alert Signup",
        public_updated_at:,
        locale: "en",
        publishing_app: "travel-advice-publisher",
        rendering_app: "email-alert-frontend",
        routes:,
        details:,
        update_type:,
      }
    end

    def content_id
      country.email_signup_content_id
    end

    def update_type
      "republish"
    end

  private

    attr_accessor :edition

    def edition_base_path
      "/foreign-travel-advice/#{edition.country_slug}"
    end

    def base_path
      "#{edition_base_path}/email-signup"
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
          links: subscriber_list_links,
        },
        summary:,
        breadcrumbs:,
        govdelivery_title: edition.title,
      }
    end

    def subscriber_list_links
      { countries: [country.content_id] }
    end

    def summary
      "You'll get an email each time #{edition.title} is updated."
    end

    def breadcrumbs
      [
        {
          title: edition.title,
          link: edition_base_path,
        },
      ]
    end

    def country
      Country.find_by_slug(edition.country_slug)
    end
  end
end
