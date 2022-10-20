FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }

    permissions { %w[signin] } if defined?(GDS::SSO::Config)
  end

  factory :travel_advice_edition do
    sequence(:country_slug) { |n| "test-country-#{n}" }
    sequence(:title) { |n| "Test Country #{n}" }
    sequence(:summary) { |n| "Travel advice about Test Country #{n}" }
    change_description { "Stuff changed" }
    update_type { "major" }
  end

  # These factories only work when used with FactoryBot.create
  factory :draft_travel_advice_edition, parent: :travel_advice_edition do
  end

  factory :published_travel_advice_edition, parent: :travel_advice_edition do
    after :create do |tae|
      tae.published_at ||= Time.zone.now.utc
      tae.state = "published"
      tae.save!
    end
  end

  factory :archived_travel_advice_edition, parent: :travel_advice_edition do
    after :create do |tae|
      tae.state = "archived"
      tae.save!
    end
  end

  factory :travel_advice_edition_with_pending_link_checks, parent: :published_travel_advice_edition do
    transient do
      batch_id { 1 }
      link_uris { [] }
      status { "pending" }
    end

    link_check_reports do
      [build(:link_check_report, :with_pending_links, batch_id:, link_uris:, status:)]
    end
  end

  factory :travel_advice_edition_with_broken_links, parent: :published_travel_advice_edition do
    id { "a-edition-id" }
    transient do
      status { "in_progress" }
      link_uris { [] }
      batch_id { 1 }
    end

    link_check_reports do
      [build(:link_check_report, :with_broken_links, status:, link_uris:, batch_id:)]
    end
  end

  factory :travel_advice_edition_with_caution_links, parent: :published_travel_advice_edition do
    transient do
      link_uris { [] }
    end

    link_check_reports do
      [build(:link_check_report, :with_caution_links, link_uris:)]
    end
  end

  factory :travel_advice_edition_with_parts, parent: :travel_advice_edition do
    summary { "This is [link](https://www.gov.uk) text." }

    after :create do |getp|
      getp.parts.build(
        title: "Some Part Title!",
        body: "This is some **version** text.",
        slug: "part-one",
      )
      getp.parts.build(
        title: "Another Part Title",
        body: "This is [link](http://www.example.com) text.",
        slug: "part-two",
      )
    end
  end

  factory :link_check_report do
    batch_id { 1 }
    status { "in_progress" }
    completed_at { Time.zone.now }
    links { [build(:link)] }

    trait :completed do
      status { "completed" }
    end

    trait :with_pending_links do
      transient do
        link_uris { [] }
      end

      links do
        link_uris.map { |uri| build(:link, :pending, uri:) }
      end
    end

    trait :with_broken_links do
      transient do
        link_uris { [] }
      end

      links do
        link_uris.map { |uri| build(:link, uri:, status: "broken") }
      end
    end

    trait :with_caution_links do
      transient do
        link_uris { [] }
      end

      links do
        link_uris.map { |uri| build(:link, uri:, status: "caution") }
      end
    end
  end

  factory :link do
    uri { "http://www.example.com" }
    status { "ok" }

    trait :pending do
      status { "pending" }
    end
  end
end
