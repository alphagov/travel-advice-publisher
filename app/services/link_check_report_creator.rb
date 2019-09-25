require "gds_api/link_checker_api"
require "govspeak/link_extractor"

class LinkCheckReportCreator
  include Rails.application.routes.url_helpers

  CALLBACK_HOST = Plek.find("travel-advice-publisher")

  def initialize(travel_advice_edition_id:)
    @travel_advice_edition_id = travel_advice_edition_id
  end

  def call
    return if uris.empty?

    link_report = call_link_checker_api.deep_symbolize_keys

    report = travel_advice_edition.link_check_reports.new(
      batch_id: link_report.fetch(:id),
      completed_at: link_report.fetch(:completed_at),
      status: link_report.fetch(:status),
      links: link_report.fetch(:links).map { |link| map_link_attrs(link) },
    )

    report.save!

    report
  end

private

  attr_reader :travel_advice_edition_id

  def travel_advice_edition
    @travel_advice_edition ||= TravelAdviceEdition.find(travel_advice_edition_id)
  end

  def call_link_checker_api
    callback = link_checker_api_callback_url(host: CALLBACK_HOST)

    GdsApi.link_checker_api.create_batch(
      uris,
      webhook_uri: callback,
      webhook_secret_token: Rails.application.secrets.link_checker_api_secret_token,
    )
  end

  def uris
    @uris ||= EditionLinkExtractor.new(edition: travel_advice_edition).call
  end

  def map_link_attrs(link)
    {
      uri: link.fetch(:uri),
      status: link.fetch(:status),
      checked_at: link.fetch(:checked),
      check_warnings: link.fetch(:warnings, []),
      check_errors: link.fetch(:errors, []),
      problem_summary: link.fetch(:problem_summary),
      suggested_fix: link.fetch(:suggested_fix),
    }
  end
end
