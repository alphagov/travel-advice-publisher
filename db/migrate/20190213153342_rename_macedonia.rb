class RenameMacedonia < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "macedonia")
      .update_all(country_slug: "north-macedonia")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "north-macedonia")
      .update_all(country_slug: "macedonia")
  end
end
