require "travel_advice_edition"
require "gds_api/asset_manager"

class TravelAdviceEdition
  after_initialize { @image_has_changed = false }
  before_save :upload_image, :if => :image_has_changed?

  def image
    unless self.image_id.blank?
      @image ||= TravelAdvicePublisher.asset_api.asset(self.image_id)
    end
  end

  def image=(image)
    @image_has_changed = true
    @image = image
  end

  def image_has_changed?
    @image_has_changed
  end

  private
    def upload_image
      response = TravelAdvicePublisher.asset_api.create_asset(:file => @image)
      self.image_id = response.id.match(/\/([^\/]+)\z/) {|m| m[1] }
    end
end
