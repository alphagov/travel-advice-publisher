require "factory_girl"

FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}"}
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }
    if defined?(GDS::SSO::Config)
      # Grant permission to signin to the app using the gem
      permissions { ["signin"] }
    end
  end

  factory :travel_advice_edition do
    sequence(:country_slug) {|n| "test-country-#{n}" }
    sequence(:title) {|n| "Test Country #{n}" }
    change_description "Stuff changed"
  end

  # These factories only work when used with FactoryGirl.create
  factory :draft_travel_advice_edition, :parent => :travel_advice_edition do
  end

  factory :published_travel_advice_edition, :parent => :travel_advice_edition do
    after :create do |tae|
      tae.published_at ||= Time.zone.now.utc
      tae.state = 'published'
      tae.save!
    end
  end

  factory :archived_travel_advice_edition, :parent => :travel_advice_edition do
    after :create do |tae|
      tae.state = 'archived'
      tae.save!
    end
  end
end
