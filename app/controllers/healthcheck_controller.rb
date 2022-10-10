class HealthcheckController < ApplicationController
  # These are inherited from ApplicationController but are not valid here
  skip_before_action :authenticate_user!
  skip_before_action :set_authenticated_user_header

  # Renders a JSON array of all travel advice editions published between
  # 2 days and 150 minutes ago. This is used by email-alert-monitoring to ensure
  # that all published editions have been sent to publishing-api and triggered
  # an email alert.
  def recently_published_editions
    editions = editions_published_between_2_days_and_150_minutes_ago.each.map do |edition|
      {
        title: edition.title,
        published_at: edition.published_at,
      }
    end

    render json: { editions: }
  end

private

  def editions_published_between_2_days_and_150_minutes_ago
    TravelAdviceEdition.published
      .where(:published_at.gte => 2.days.ago,
             :published_at.lte => 150.minutes.ago)
      .order_by(published_at: :desc)
  end
end
