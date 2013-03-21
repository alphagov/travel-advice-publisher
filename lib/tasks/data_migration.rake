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

  desc "Populate search and change descriptions"
  task :update_descriptions => :environment do
    Country.all.each do |country|
      eds = country.editions.to_a
      unless eds.any?
        puts "No editions found for #{country.slug}"
        next
      end
      eds.each do |ed|
        if ed.minor_update? and ed.draft?
          puts "Skipping updating change_description for minor draft for #{country.name} v#{ed.version_number}"
        else
          ed.change_description = <<-EOT
Travel advice for #{country.name} has been published for the first time on the new government website, [GOV.UK](https://www.gov.uk/ "GOV.UK"). 

There are no major changes to the advice.
          EOT
        end
        ed.overview = "Travel advice for #{country.name}"
        ed.save!(:validate => false)
      end
    end
  end
end

