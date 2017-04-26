class PartPresenter
  def self.present(part)
    new(part).present
  end

  def initialize(part)
    @part = part
  end

  def present
    {
      "slug" => part.slug,
      "title" => part.title,
      "body" => [
        { "content_type" => "text/govspeak", "content" => part.body },
      ],
    }
  end

private

  attr_accessor :part
end
