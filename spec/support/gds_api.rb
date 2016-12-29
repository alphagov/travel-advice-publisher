module GdsApiHelpers
  def stub_rummager
    allow(TravelAdvicePublisher.rummager).to receive(:add_document)
  end

  def stub_shared_templates
    WebMock.stub_request(:get, %r{\A#{Plek.current.find('static')}/templates}).
      to_return(status: 200, body: "{}")
  end
end

RSpec.configuration.include GdsApiHelpers, :type => :model

RSpec.configuration.include GdsApiHelpers, :type => :controller
RSpec.configuration.before :each, :type => :controller do
  stub_rummager
  stub_shared_templates
end

RSpec.configuration.include GdsApiHelpers, :type => :feature
RSpec.configuration.before :each, :type => :feature do
  stub_shared_templates
end

RSpec.configuration.include GdsApiHelpers, :type => :rake_task
