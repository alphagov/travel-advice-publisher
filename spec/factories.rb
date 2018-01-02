require "factory_girl"

FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }
    if defined?(GDS::SSO::Config)
      # Grant permission to signin to the app using the gem
      permissions { ["signin"] }
    end
  end

  factory :travel_advice_edition do
    sequence(:country_slug) { |n| "test-country-#{n}" }
    sequence(:title) { |n| "Test Country #{n}" }
    sequence(:summary) { |n| "Travel advice about Test Country #{n}" }
    change_description "Stuff changed"
  end

  # These factories only work when used with FactoryGirl.create
  factory :draft_travel_advice_edition, parent: :travel_advice_edition do
  end

  factory :published_travel_advice_edition, parent: :travel_advice_edition do
    after :create do |tae|
      tae.published_at ||= Time.zone.now.utc
      tae.state = 'published'
      tae.save!
    end
  end

  factory :archived_travel_advice_edition, parent: :travel_advice_edition do
    after :create do |tae|
      tae.state = 'archived'
      tae.save!
    end
  end

  factory :travel_advice_edition_with_pending_link_checks, parent: :published_travel_advice_edition do
    transient do
      batch_id 1
      link_uris []
    end

    link_check_reports do
      [FactoryGirl.build(:link_check_report, :with_pending_links,
                                             batch_id: batch_id,
                                             link_uris: link_uris)]
    end
  end

  factory :link_check_report do
    batch_id 1
    status "in_progress"
    completed_at Time.now
    links { [FactoryGirl.build(:link)] }

    trait :completed do
      status "completed"
    end

    trait :with_pending_links do
      transient do
        link_uris []
      end

      links do
        link_uris.map { |uri| FactoryGirl.build(:link, :pending, uri: uri) }
      end
    end
  end

  factory :link do
    uri "http://www.example.com"
    status "ok"

    trait :pending do
      status "pending"
    end
  end
end
