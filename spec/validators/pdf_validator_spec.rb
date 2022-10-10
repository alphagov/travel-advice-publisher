RSpec.describe PdfValidator do
  before do
    document_with_pdf_class = Class.new do
      include Mongoid::Document

      field "pdf", type: File

      validates :pdf, pdf: true
    end

    stub_const("DocumentWithPdf", document_with_pdf_class)
  end

  let(:pdf) { nil }
  let(:document) { DocumentWithPdf.new(pdf:) }

  shared_examples "is valid" do
    it "should be valid" do
      expect(document).to be_valid
      expect(document.errors).to be_empty
    end
  end

  shared_examples "is invalid" do
    it "should be invalid" do
      expect(document).to_not be_valid
      expect(document.errors[:pdf]).to_not be_empty
    end
  end

  context "given no PDF" do
    include_examples "is valid"
  end

  context "given an HTML file" do
    let(:pdf) { file_fixture("example.html").open }
    include_examples "is invalid"
  end

  context "given a PDF file" do
    let(:pdf) { file_fixture("example.pdf").open }
    include_examples "is valid"
  end

  context "given a PDF file with an HTML extension" do
    let(:pdf) { file_fixture("example.pdf.html").open }
    include_examples "is invalid"
  end

  context "given an HTML file with a PDF extension" do
    let(:pdf) { file_fixture("example.html.pdf").open }
    include_examples "is invalid"
  end
end
