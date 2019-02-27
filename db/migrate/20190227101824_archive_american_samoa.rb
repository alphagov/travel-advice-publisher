class ArchiveAmericanSamoa < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "american-samoa", state: "published")
      .update_all(state: "archived")
  end

  def self.down
  end
end
