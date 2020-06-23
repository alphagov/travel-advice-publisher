class ChangeMinorUpdateBooleanToUpdateTypeString < Mongoid::Migration
  def self.up
    TravelAdviceEdition.where(minor_update: true, update_type: nil).update_all(update_type: "minor")
    TravelAdviceEdition.where(minor_update: false, update_type: nil).update_all(update_type: "major")
  end

  def self.down
    TravelAdviceEdition.where(update_type: "minor").update_all(minor_update: true, update_type: nil)
    TravelAdviceEdition.where(update_type: "major").update_all(minor_update: false, update_type: nil)
  end
end
