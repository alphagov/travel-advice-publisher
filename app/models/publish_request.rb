class PublishRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :edition_id
  field :request_id
  field :checks_attempted, type: Array, default: []
  field :succeeded, type: Boolean, default: false
  field :checks_complete, type: Boolean, default: false
  field :frontend_updated, type: Boolean, default: false
  field :country_slug, type: String

  MAX_RETRIES = 3

  def self.awaiting_check
    #returns the most recent per country_slug
    #with checks_complete == false
    #and created_at more than 5 minutes ago
    ids = collection.aggregate(
      [
        { "$sort" => { country_slug: 1, created_at: 1 } },
        {
          "$group" => {
            _id: "$country_slug",
            latestId: { "$last" => "$_id" }
          }
        },
        {
          "$group" => {
            _id: "$latestId"
          }
        }
      ]
    ).map { |result| result["_id"] }
    where(:_id.in => ids)
      .where(checks_complete: false)
      .where(:created_at.lt => 5.minutes.ago)
  end

  def register_check_attempt!
    self.checks_attempted << Time.now
    self.checks_complete = check_count >= MAX_RETRIES
    if self.frontend_updated?
      self.succeeded = true
      self.checks_complete = true
    end
    save!
  end

  def mark_frontend_updated
    self.frontend_updated = true
  end

  def check_count
    checks_attempted.length
  end
end
