class FixReviewedDates < Mongoid::Migration
  def self.up
    TravelAdviceEdition.published.order_by(%i[country_slug asc]).each do |ed|
      non_draft_eds = TravelAdviceEdition.without_state("draft").where(country_slug: ed.country_slug)
      # reviewed_at date should always increase, so the correct date will be the latest one.
      correct_date = non_draft_eds.desc(:reviewed_at).first.reviewed_at
      if correct_date && (correct_date != ed.reviewed_at)
        puts "Updating #{ed.country_slug} from #{ed.reviewed_at} to #{correct_date}"
        ed.reviewed_at = correct_date
        ed.save!
      end
    end
  end

  def self.down; end
end
