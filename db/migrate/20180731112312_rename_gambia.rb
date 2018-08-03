class RenameGambia < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "gambia")
      .update_all(country_slug: "the-gambia")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "the-gambia")
      .update_all(country_slug: "gambia")
  end
end
