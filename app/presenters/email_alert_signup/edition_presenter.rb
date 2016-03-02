module EmailAlertSignup
  class EditionPresenter
    def initialize(edition)
      self.edition = edition
    end

    def content_payload
      {
        content_id: content_id,
        base_path: base_path,
        format: "email_alert_signup",
        title: edition.title,
        description: "#{edition.title} Email Alert Signup",
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
        subscriber_list_document_type: "travel_advice",
        signup_tags: tags,
        summary: summary,
        breadcrumbs: breadcrumbs,
        govdelivery_title: edition.title,
      }
    end

    def tags
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
        }
      ]
    end

    def country
      Country.find_by_slug(edition.country_slug)
    end
  end
end
