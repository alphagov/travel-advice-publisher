class RenameSwaziland < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "swaziland")
      .update_all(country_slug: "eswatini")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "eswatini")
      .update_all(country_slug: "swaziland")
  end
end
