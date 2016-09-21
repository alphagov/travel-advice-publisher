namespace :rummager do
  desc "Indexes the main travel advice page in Rummager"
  task index: :environment do
    slug = "foreign-travel-advice"
    record = OpenStruct.new(
      slug: slug,
      content_id: TravelAdvicePublisher::INDEX_CONTENT_ID,
      title: "Foreign travel advice",
      description: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health",
      indexable_content: "Latest travel advice by country including safety and security, entry requirements, travel warnings and health"
    )

    RummagerNotifier.notify(record)
  end

  desc 'Indexes all published travel advice pages in Rummager'
  task index_all: :environment do
    TravelAdviceEdition.published.each do |edition|
      details = RegisterableTravelAdviceEdition.new(edition)
      RummagerNotifier.notify(details)
    end
  end
end
