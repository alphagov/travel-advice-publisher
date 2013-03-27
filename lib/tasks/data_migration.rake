# encoding: UTF-8

namespace :data_migration do

  desc "Convert change_descriptions from govspeak to plain text"
  task :degovspeak_change_descriptions => :environment do
    TravelAdviceEdition.all.each do |ed|
      next unless ed.change_description.present?
      ed.change_description = Govspeak::Document.new(ed.change_description).to_text
      ed.save(:validate => false)
    end
  end
end
