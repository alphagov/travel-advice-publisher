class UpdateCookIslands < Mongoid::Migration
  def self.up
    TravelAdviceEdition
      .where(country_slug: "cook-islands-tokelau-and-nieu")
      .update_all(country_slug: "cook-islands-tokelau-and-niue")
  end

  def self.down
    TravelAdviceEdition
      .where(country_slug: "cook-islands-tokelau-and-niue")
      .update_all(country_slug: "cook-islands-tokelau-and-nieu")
  end
end
