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

  factory :disabled_user, parent: :user do
    disabled true
  end

  factory :edition, class: TravelAdviceEdition do
    panopticon_id 0
    transient do
      version_number nil
    end

    sequence(:slug) { |n| "slug-#{n}" }
    sequence(:title) { |n| "A key answer to your question #{n}" }

    after :build do |ed, evaluator|
      if !evaluator.version_number.nil?
        ed.version_number = evaluator.version_number
      elsif (previous = ed.series.order(version_number: "desc").first)
        ed.version_number = previous.version_number + 1
      end
    end

    trait :scheduled_for_publishing do
      state 'scheduled_for_publishing'
      publish_at 1.day.from_now
    end

    trait :published do
      state 'published'
    end

    trait :with_body do
      body 'Some body text'
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
