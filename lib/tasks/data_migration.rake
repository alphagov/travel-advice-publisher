namespace :data_migration do

  desc "Updates country_slugs on TAEditions"
  task :update_country_slugs => :environment do
    {
      'cote-d-ivoire-ivory-coast' => 'cote-d-ivoire',
      'commonwealth-of-dominica' => 'dominica',
      'korea' => 'south-korea',
      'russian-federation' => 'russia',
      'st-helena' => 'st-helena-ascension-and-tristan-da-cunha',
    }.each do |old_slug, new_slug|
      puts "Changing #{old_slug} => #{new_slug}"
      TravelAdviceEdition.where(:country_slug => old_slug).each do |ed|
        ed.country_slug = new_slug
        ed.save!(:validate => false)
      end
    end
  end
end

