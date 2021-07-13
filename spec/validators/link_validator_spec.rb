describe LinkValidator do
  before do
    link_validator_dummy_class = Class.new do
      include Mongoid::Document

      field "body", type: String
      field "assignee", type: String

      validates_with LinkValidator
    end

    stub_const("LinkValidatorDummy", link_validator_dummy_class)
    stub_const("LinkValidatorDummy::GOVSPEAK_FIELDS", %i[body])
  end

  let(:body) { nil }
  subject(:doc) { LinkValidatorDummy.new(body: body) }

  shared_examples "is valid" do
    it "should be valid" do
      expect(doc).to be_valid
      expect(doc.errors).to be_empty
    end
  end

  shared_examples "is invalid" do
    it "should be invalid" do
      expect(doc).to_not be_valid
      expect(doc.errors[:body]).to_not be_empty
    end
  end

  context "blank govspeak fields" do
    include_examples "is valid"
  end

  context "body is a non-empty string" do
    let(:body) { "Nothing is invalid" }
    include_examples "is valid"
  end

  context "starts with no protocol" do
    let(:body) { "abc [external](external.com)" }
    include_examples "is invalid"
  end

  context "starts with http://" do
    let(:body) { "abc [external](http://external.com)" }
    include_examples "is valid"
  end

  context "starts with /" do
    let(:body) { "abc [internal](/internal)" }
    include_examples "is valid"
  end

  context "does not contain hover text" do
    let(:body) { 'abc [foobar](http://foobar.com "hover")' }
    include_examples "is invalid"
  end

  context "smart quotes as normal quotes" do
    let(:body) { "abc [foobar](http://foobar.com “hover”)" }
    include_examples "is invalid"
  end

  context "not set rel=external" do
    let(:body) { 'abc [foobar](http://foobar.com){:rel="external"}' }
    include_examples "is invalid"
  end

  context "has more than one error" do
    let(:body) { 'abc [foobar](foobar.com "bar"){:rel="external"}' }

    include_examples "is invalid"

    it "should have 3 errors" do
      doc.validate
      expect(doc.errors[:body].first.length).to eq(3)
    end
  end

  context "has multiple instances of the same error" do
    let(:body) { "abc [link1](foobar.com), ghi [link2](bazquux.com)" }

    include_examples "is invalid"

    it "should have 1 error" do
      doc.validate
      expect(doc.errors[:body].first.length).to eq(1)
    end
  end
end
