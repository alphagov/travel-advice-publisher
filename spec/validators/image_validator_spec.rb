RSpec.describe ImageValidator do
  before do
    document_class = Class.new do
      include Mongoid::Document

      field "image", type: File

      validates :image, image: true
    end

    stub_const("Document", document_class)
  end

  let(:image) { nil }
  let(:document) { Document.new(image:) }

  shared_examples "is valid" do
    it "should be valid" do
      expect(document).to be_valid
      expect(document.errors).to be_empty
    end
  end

  shared_examples "is invalid" do
    it "should be invalid" do
      expect(document).to_not be_valid
      expect(document.errors[:image]).to_not be_empty
    end
  end

  context "given no image" do
    include_examples "is valid"
  end

  context "given an HTML file" do
    let(:image) { file_fixture("example.html").open }
    include_examples "is invalid"
  end

  context "given a PNG file" do
    let(:image) { file_fixture("example.png").open }
    include_examples "is valid"
  end

  context "given an HTML file with a PNG extension" do
    let(:image) { file_fixture("example.html.png").open }
    include_examples "is invalid"
  end

  context "given a JPEG file" do
    let(:image) { file_fixture("example.jpg").open }
    include_examples "is valid"
  end

  context "given a JPEG with a PNG extension" do
    let(:image) { file_fixture("example.jpg.png").open }
    include_examples "is invalid"
  end
end
