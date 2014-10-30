require "gds_api/test_helpers/panopticon"

module GdsApiHelpers
  def stub_panopticon_registration
    GdsApi::Panopticon::Registerer.any_instance.stub(:register)
  end

  # Fallback to using WebMock so that we can filter on draft registrations only.
  def stub_panopticon_draft_registration
    WebMock.stub_request(:put, %r{\A#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts}).
      with(:body => hash_including('state' => 'draft')).
      to_return(:status => 200, :body => "{}")
  end

  def stub_artefact_related_items_update
    WebMock.stub_request(:put, %r{\A#{GdsApi::TestHelpers::Panopticon::PANOPTICON_ENDPOINT}/artefacts/foreign-travel-advice}).
      with(:body => hash_including('related_artefact_ids' => anything)).
      to_return(:status => 200, :body => "{}")
  end
end

RSpec.configuration.include GdsApiHelpers, :type => :model
RSpec.configuration.before :each, :type => :model do
  stub_panopticon_registration
end

RSpec.configuration.include GdsApiHelpers, :type => :controller
RSpec.configuration.include GdsApi::TestHelpers::Panopticon, :type => :controller
RSpec.configuration.before :each, :type => :controller do
  stub_panopticon_registration
end

RSpec.configuration.include GdsApiHelpers, :type => :feature
RSpec.configuration.include GdsApi::TestHelpers::Panopticon, :type => :feature
RSpec.configuration.before :each, :type => :feature do
  stub_panopticon_draft_registration
end
