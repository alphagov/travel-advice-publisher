require "spec_helper"

RSpec.describe GovspeakPresenter do
  it "presents the given govspeak as multiple content types" do
    result = subject.present("### Title\r\nParagraph")

    expect(result).to eq [
      { "content_type" => "text/govspeak", "content" => "### Title\r\nParagraph" },
      { "content_type" => "text/html", "content" => "<h3 id=\"title\">Title</h3>\n<p>Paragraph</p>\n" },
    ]
  end
end
