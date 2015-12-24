class PartPresenter
  def self.present(part)
    new(part).present
  end

  def initialize(part)
    self.part = part
  end

  def present
    {
      "slug" => part.slug,
      "title" => part.title,
      "body" => part.body,
    }
  end

private
  attr_accessor :part
end
