describe SafeHtml do
  class Dummy
    include Mongoid::Document

    field :i_am_govspeak, type: String

    GOVSPEAK_FIELDS = [:i_am_govspeak].freeze

    validates_with SafeHtml

    embeds_one :dummy_embedded_single, class_name: 'DummyEmbeddedSingle'
  end

  class DummyEmbeddedSingle
    include Mongoid::Document

    embedded_in :dummy, class_name: 'Dummy'

    field :i_am_govspeak, type: String

    GOVSPEAK_FIELDS = [:i_am_govspeak].freeze

    validates_with SafeHtml
  end

  shared_examples "is valid" do
    it "should be valid" do
      expect(dummy).to be_valid
      expect(dummy.errors).to be_empty
    end
  end

  shared_examples "is invalid" do
    it "should be invalid" do
      expect(dummy).to be_invalid
      expect(dummy.errors[:i_am_govspeak]).to_not be_empty
    end
  end

  subject(:dummy) { Dummy.new(i_am_govspeak: i_am_govspeak) }

  context "with an invalid embedded document" do
    let(:i_am_govspeak) { "" }

    before do
      dummy.dummy_embedded_single = DummyEmbeddedSingle.new(i_am_govspeak: "<script>")
    end

    it "should be invalid" do
      expect(dummy).to be_invalid
    end
  end

  context "clean content in nested fields" do
    let(:i_am_govspeak) { { "clean" => ["plain text"] } }
    include_examples "is valid"
  end

  context "disallow images not hosted by us" do
    let(:i_am_govspeak) { '<img src="http://evil.com/trollface"/>' }
    include_examples "is invalid"
  end

  context "images hosted by us" do
    let(:i_am_govspeak) { '<img src="http://www.dev.gov.uk/trollface"/>' }
    include_examples "is valid"
  end

  context "plain text" do
    let(:i_am_govspeak) { "foo bar" }
    include_examples "is valid"
  end

  context "only specified fields as Govspeak" do
    let(:i_am_govspeak) { '[Numberwang](script:nasty(); "Wangernum")' }
    let(:doc) { Govspeak::Document.new(i_am_govspeak) }

    it "should have an invalid document" do
      expect(doc).to_not be_valid
    end

    include_examples "is invalid"
  end

  context "all models that have govspeak fields" do
    it "should use this validator" do
      models_dir = File.expand_path("../../app/models/*", File.dirname(__FILE__))

      Dir[models_dir]
        .map { |file| File.basename(file, ".rb").camelize.constantize }
        .select { |klass| klass.included_modules.include?(Mongoid::Document) && klass.const_defined?(:GOVSPEAK_FIELDS) }
        .each { |klass| expect(klass.validators.map(&:class)).to include(SafeHtml) }
    end
  end
end
