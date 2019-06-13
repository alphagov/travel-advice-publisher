class RenameBurmaToMyanmar < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "burma")
      .update_all(country_slug: "myanmar")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "myanmar")
      .update_all(country_slug: "burma")
  end
end
