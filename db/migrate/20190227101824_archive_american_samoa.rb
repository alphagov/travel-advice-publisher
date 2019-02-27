class ArchiveAmericanSamoa < Mongoid::Migration
  def change
    TravelAdviceEdition
      .where(country_slug: "american-samoa", state: "published")
      .update_all(state: "archived")
  end
end
