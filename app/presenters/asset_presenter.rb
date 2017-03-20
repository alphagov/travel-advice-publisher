class AssetPresenter
  def self.present(asset)
    new(asset).present
  end

  def initialize(asset)
    self.asset = asset
  end

  def present
    if asset
      {
        "url" => asset.file_url,
        "content_type" => asset.content_type,
      }
    end
  end

private

  attr_accessor :asset
end
