describe Scheduling do
  describe "validations" do
    let(:ta) { build(:travel_advice_edition) }
    let(:scheduling) { ta.build_scheduling(scheduled_publish_time: Time.zone.now + 1.hour) }

    it "is valid with published time in the future" do
      expect(scheduling).to be_valid
    end

    it "is not valid without a scheduled publish time" do
      scheduling.scheduled_publish_time = nil

      expect(scheduling).to_not be_valid
    end

    it "is not valid if scheduled time is in the past" do
      scheduling.scheduled_publish_time = Time.zone.now - 1.hour

      expect(scheduling).to_not be_valid
      expect(scheduling.errors.full_messages).to include(/Scheduled publish time can't be in the past/)
    end
  end
end
