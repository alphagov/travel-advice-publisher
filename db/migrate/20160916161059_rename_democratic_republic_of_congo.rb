class RenameDemocraticRepublicOfCongo < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "democratic-republic-of-congo")
      .update_all(country_slug: "democratic-republic-of-the-congo")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "democratic-republic-of-the-congo")
      .update_all(country_slug: "democratic-republic-of-congo")
  end
end
