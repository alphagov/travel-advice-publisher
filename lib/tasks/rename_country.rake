namespace :country do
  desc "Rename a country"
  task :rename, %i[old_country_slug new_country_slug] => :environment do |_task, args|
    if args.old_country_slug.blank? || args.new_country_slug.blank?
      raise ArgumentError, "This task takes two arguments: the current country slug and the new country slug."
    end

    puts "Renaming #{args.old_country_slug} to #{args.new_country_slug}..."
    TravelAdviceEdition.where(country_slug: args.old_country_slug).update_all(country_slug: args.new_country_slug)
  end
end
