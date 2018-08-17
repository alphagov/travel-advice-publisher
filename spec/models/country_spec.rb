require 'spec_helper'

describe Country do
  describe "Country.all" do
    it "should return a list of Countries" do
      expect(Country.all.size).to eq(13)
      expect(Country.all.first.name).to eq("Afghanistan")
      expect(Country.all.first.slug).to eq("afghanistan")
      expect(Country.all.find { |c| c.slug == "argentina" }.name).to eq("Argentina")
    end
  end

  describe "Country.find_by_slug" do
    it "returns a Country given a valid slug" do
      country = Country.find_by_slug('argentina')

      expect(country).to be_a Country
      expect(country.slug).to eq("argentina")
      expect(country.name).to eq("Argentina")
    end

    it "returns nil given an invalid slug" do
      country = Country.find_by_slug('oceania')

      expect(country).to be_nil
    end
  end

  describe "finding editions for a country" do
    before :each do
      @country = Country.all.first
    end

    it "should return all TravelAdviceEditions with the matching country_slug" do
      e1 = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug)
      _e2 = FactoryBot.create(:archived_travel_advice_edition, country_slug: "wibble")
      e3 = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug)

      expect(@country.editions.to_a).to match_array([e1, e3])
    end

    it "should order them by descending version_number" do
      e1 = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug, version_number: 1)
      e3 = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug, version_number: 3)
      e2 = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug, version_number: 2)

      expect(@country.editions.to_a).to eq([e3, e2, e1])
    end
  end

  describe "#last_published_edition" do
    before do
      @country = Country.all.first

      @archived = FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug, version_number: 1)
      @published = FactoryBot.create(:published_travel_advice_edition, country_slug: @country.slug, version_number: 2)
      @draft = FactoryBot.create(:draft_travel_advice_edition, country_slug: @country.slug, version_number: 3)
    end

    it "should return the last published edition for the country" do
      expect(@country.last_published_edition.version_number).to eq(2)
    end

    context "when there are no published editions for the country" do
      before do
        @published.destroy
      end

      it "should return nil" do
        expect(@country.last_published_edition).to be_nil
      end
    end
  end

  describe "has_{state}_edition?" do
    before :each do
      @country = Country.find_by_slug('aruba')
    end

    it "should be false with no editions" do
      expect(@country.has_published_edition?).to eq(false)
      expect(@country.has_draft_edition?).to eq(false)
    end

    it "should match published editions correctly" do
      FactoryBot.create(:published_travel_advice_edition, country_slug: @country.slug)
      expect(@country.has_published_edition?).to eq(true)
      expect(@country.has_draft_edition?).to eq(false)
    end

    it "should match draft editions correctly" do
      FactoryBot.create(:draft_travel_advice_edition, country_slug: @country.slug)
      expect(@country.has_published_edition?).to eq(false)
      expect(@country.has_draft_edition?).to eq(true)
    end

    it "should be false with editions in other states" do
      FactoryBot.create(:archived_travel_advice_edition, country_slug: @country.slug)
      expect(@country.has_published_edition?).to eq(false)
      expect(@country.has_draft_edition?).to eq(false)
    end
  end

  describe "build_new_edition" do
    before :each do
      @country = Country.find_by_slug('aruba')
    end

    it "should build a clone of the latest edition if present" do
      ed1 = FactoryBot.build(:travel_advice_edition)
      ed2 = FactoryBot.build(:travel_advice_edition)
      ed3 = FactoryBot.build(:travel_advice_edition)
      allow(@country).to receive(:editions).and_return([ed3, ed2, ed1])
      expect(ed3).to receive(:build_clone).and_return(:a_new_edition)

      expect(@country.build_new_edition).to eq(:a_new_edition)
    end

    it "should build a new edition if there are no existing editions" do
      ed = @country.build_new_edition
      expect(ed).to be_new_record
      expect(ed.country_slug).to eq('aruba')
      expect(ed.title).to eq("Aruba travel advice")
    end
  end

  describe "build_new_edition_as" do
    before :each do
      @user = FactoryBot.create(:user)
      @country = Country.find_by_slug('aruba')
    end

    it "should build out a new edition with a create action" do
      edition = @country.build_new_edition_as(@user)

      expect(edition.actions.size).to eq(1)
      expect(edition.actions.first.requester).to eq(@user)
      expect(edition.actions.first.request_type).to eq(Action::NEW_VERSION)
    end

    describe "providing an optional edition parameter" do
      before :each do
        @edition = FactoryBot.create(:archived_travel_advice_edition,
          country_slug: @country.slug, title: "A test title",
          overview: "Meh")
      end

      it "should build a clone of the provided edition" do
        edition = @country.build_new_edition_as(@user, @edition)

        expect(edition._id).not_to eq(@edition._id)
        expect(edition.title).to eq(@edition.title)
        expect(edition.overview).to eq(@edition.overview)
      end
    end
  end
end
