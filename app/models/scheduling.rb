class Scheduling
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :travel_advice_edition

  field :scheduled_publish_time, type: Time
  validates :scheduled_publish_time, presence: true
  validate :validate_scheduled_published_time

  def schedule_for_publication(edition)
    edition.schedule
  end

private

  def validate_scheduled_published_time
    errors.add(:scheduled_publish_time, "can't be in the past") if scheduled_publish_time && scheduled_publish_time <= Time.zone.now
  end
end
