require 'spec_helper'
require 'gds_api/test_helpers/rummager'

RSpec.describe SearchIndexer do
  include GdsApi::TestHelpers::Rummager

  before do
    stub_any_rummager_post_with_queueing_enabled
  end

  it 'indexes the travel advice page in rummager' do
    country_page = Country.find_by_slug('aruba')
    edition = country_page.build_new_edition
    travel_advice_edition = RegisterableTravelAdviceEdition.new(edition)

    described_class.call(travel_advice_edition)

    assert_rummager_posted_item(
      _type: 'edition',
      _id: "/#{travel_advice_edition.slug}",
      rendering_app: 'government-frontend',
      publishing_app: 'travel-advice-publisher',
      format: "custom-application",
      title: travel_advice_edition.title,
      description: travel_advice_edition.description,
      indexable_content: travel_advice_edition.indexable_content,
      link: "/#{travel_advice_edition.slug}"
    )
  end
end
