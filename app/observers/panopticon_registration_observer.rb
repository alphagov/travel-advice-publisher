require 'registerable_travel_advice_edition'
require 'gds_api/panopticon'

class PanopticonRegistrationObserver < Mongoid::Observer
  observe :travel_advice_edition

  def after_publish(edition, transition)
    register_with_panopticon(edition)
  end

  private

  def register_with_panopticon(edition)
    details = RegisterableTravelAdviceEdition.new(edition)
    registerer = GdsApi::Panopticon::Registerer.new(owning_app: 'travel-advice-publisher', rendering_app: "frontend", kind: 'travel-advice')
    registerer.register(details)
  end
end
