namespace :data_migration do

  desc "Updates country_slugs on TAEditions"
  task :update_country_slugs => :environment do
    {
      'congo-democratic-republic' => 'democratic-republic-of-congo',
      'cote-d-ivoire-ivory-coast' => 'cote-d-ivoire',
      'commonwealth-of-dominica' => 'dominica',
      'korea' => 'south-korea',
      'pitcairn' => 'pitcairn-island',
      'russian-federation' => 'russia',
      'united-states' => 'usa',
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

