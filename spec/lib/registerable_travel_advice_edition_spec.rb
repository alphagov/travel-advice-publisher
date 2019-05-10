describe RegisterableTravelAdviceEdition do
  describe "state" do
    before :each do
      @edition = FactoryBot.build(:travel_advice_edition)
    end

    it "should be 'live' for a published edition" do
      @edition.state = 'published'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('live')
    end

    it "should be 'archived' for an archived edition" do
      @edition.state = 'archived'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('archived')
    end

    it "should be 'draft' for a draft edition" do
      @edition.state = 'draft'
      expect(RegisterableTravelAdviceEdition.new(@edition).state).to eq('draft')
    end
  end

  describe "simple fields" do
    before :each do
      @edition = FactoryBot.build(:travel_advice_edition)
      @registerable = RegisterableTravelAdviceEdition.new(@edition)
    end

    it "should return the edition's overview for description" do
      @edition.overview = 'fooey gooey kablooie'
      expect(@registerable.description).to eq('fooey gooey kablooie')
    end

    it "should return the edition's country_slug with travel_advice prepended" do
      expect(@registerable.slug).to eq("foreign-travel-advice/#{@edition.country_slug}")
    end

    it "should return the edition's title" do
      @edition.title = "Aruba travel advice"
      expect(@registerable.title).to eq("Aruba travel advice")
    end

    context "paths" do
      it "should include /<slug>.atom" do
        expect(@registerable.paths).to include("/foreign-travel-advice/#{@edition.country_slug}.atom")
      end

      it "should include /<slug>" do
        expect(@registerable.paths).to include("/foreign-travel-advice/#{@edition.country_slug}")
      end

      it "should include /<slug>/print" do
        expect(@registerable.paths).to include("/foreign-travel-advice/#{@edition.country_slug}/print")
      end

      it "should include /<slug>/<part.slug>" do
        @edition.parts << Part.new(title: "Foo", body: "Bar", slug: "foo")
        expect(@registerable.paths).to include("/foreign-travel-advice/#{@edition.country_slug}/foo")
      end
    end

    it "should have no prefix paths" do
      expect(@registerable.prefixes).to be_empty
    end
  end

  describe "content_id" do
    before :each do
      @edition = FactoryBot.build(:travel_advice_edition)
      @registerable = RegisterableTravelAdviceEdition.new(@edition)
    end

    it "should return the content_id of the corresponding country" do
      @edition.country_slug = 'albania'
      expect(@registerable.content_id).to eq('2a3938e1-d588-45fc-8c8f-0f51814d5409') # From countries.yml fixture
    end

    it "should return nil if there is no corresponding country" do
      @edition.country_slug = 'non-existent'
      expect(@registerable.content_id).to be_nil
    end
  end
end
