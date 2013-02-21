require "travel_advice_edition"
require "asset_uploader"

class TravelAdviceEdition
  attr_accessor :image

  after_initialize { @image_has_changed = false }
  before_save :upload_image, :if => :image_has_changed?

  def image=(image)
    @image_has_changed = true
    @image = image
  end

  def image_has_changed?
    @image_has_changed
  end

  private
    def upload_image
      uploader = AssetUploader.new(Plek.current.find('asset-manager'))
      response = uploader.upload(image)

      self.image_id = JSON.parse(response.body)['id']
    end
end
