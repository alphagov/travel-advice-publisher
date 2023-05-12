namespace :db do
  desc "move summary from details into parts for one country"
  task :migrate_summary, [:country_slug] => :environment do |_task, args|
    country = Country.find_by_slug(args[:country_slug])
    raise "Could not find country #{args[:country_slug]}" unless country

    migrate_summary_for(country)
  end

  desc "move summary from details into parts for one country"
  task migrate_summary_all_countries: :environment do
    Country.all.map { |country| migrate_summary_for(country) }
  end
end

def migrate_summary_for(country)
  unless country.has_published_edition?
    puts "no published editions found for #{country.slug}...skipping"
    return
  end

  if country.has_draft_edition?
    puts "draft edition found for #{country.slug}...skipping"
    return
  end

  published_edition = country.last_published_edition
  new_edition = country.build_new_edition(published_edition)
  new_edition.save!

  summary = new_edition.summary
  if summary.nil?
    puts "no summary found for #{country.slug}...skipping"
    return
  end

  new_edition.summary = nil
  new_edition.parts.map do |part|
    part.order += 1 if part.order
  end
  new_edition.parts.build(
    order: 1,
    title: "Summary",
    slug: "summary",
    body: summary,
  )

  new_edition.minor_update = true
  new_edition.update_type = "minor"

  new_edition.publish
  new_edition.save!
  puts "SUCCEED: Summary has moved into parts for country: #{country.slug}"
end
