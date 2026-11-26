namespace :tmp do
  desc "Rename countries and republish affected content"
  task rename_countries: :environment do
    countries = {
      "nauru" => "naoero",
      "bonaire-st-eustatius-saba" => "bonaire-sint-eustatius-saba",
      "st-maarten" => "sint-maarten",
      "bahamas" => "the-bahamas",
    }

    run_task = lambda do |name, *args|
      task = Rake::Task[name]
      task.reenable
      task.invoke(*args)
    end

    countries.each do |old_slug, new_slug|
      puts "Updating #{old_slug} to #{new_slug}"

      run_task.call("country:rename", old_slug, new_slug)
      run_task.call("publishing_api:republish_edition", new_slug)
      run_task.call(
        "publishing_api:republish_email_signups:country_edition",
        new_slug,
      )
    end
  end
end
