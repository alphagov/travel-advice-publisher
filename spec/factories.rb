FactoryBot.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }

    transient do
      preview_design_system { false }
    end

    if defined?(GDS::SSO::Config)
      permissions do
        [
          "signin",
          ("Preview Design System" if preview_design_system),
        ].compact
      end
    end

    trait :with_design_system_permission do
      permissions { ["signin", "Preview Design System"] }
    end
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
      [build(:link_check_report, :with_pending_links, batch_id: batch_id, link_uris: link_uris, status: status)]
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
      [build(:link_check_report, :with_broken_links, status: status, link_uris: link_uris, batch_id: batch_id)]
    end
  end

  factory :travel_advice_edition_with_caution_links, parent: :published_travel_advice_edition do
    transient do
      link_uris { [] }
    end

    link_check_reports do
      [build(:link_check_report, :with_caution_links, link_uris: link_uris)]
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
        link_uris.map { |uri| build(:link, :pending, uri: uri) }
      end
    end

    trait :with_broken_links do
      transient do
        link_uris { [] }
      end

      links do
        link_uris.map { |uri| build(:link, uri: uri, status: "broken") }
      end
    end

    trait :with_caution_links do
      transient do
        link_uris { [] }
      end

      links do
        link_uris.map { |uri| build(:link, uri: uri, status: "caution") }
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
