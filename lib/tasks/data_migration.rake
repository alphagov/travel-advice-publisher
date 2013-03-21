namespace :data_migration do

  desc "Updates country_slugs on TAEditions"
  task :update_country_slugs => :environment do
    {
      'st-helena' => 'st-helena-ascension-and-tristan-da-cunha',
    }.each do |old_slug, new_slug|
      puts "Changing #{old_slug} => #{new_slug}"
      TravelAdviceEdition.where(:country_slug => old_slug).each do |ed|
        ed.country_slug = new_slug
        ed.save! :validate => false
      end
      if a = Artefact.find_by_slug("foreign-travel-advice/#{old_slug}")
        puts "  Updating artefact slug"
        a.slug = "foreign-travel-advice/#{new_slug}"
        a.save! :validate => false
      end
    end
  end
end

