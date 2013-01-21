module GdsApiHelpers
  def stub_panopticon_registration
    GdsApi::Panopticon::Registerer.any_instance.stub(:register)
  end
end

RSpec.configuration.include GdsApiHelpers, :type => :controller
RSpec.configuration.include GdsApiHelpers, :type => :feature
