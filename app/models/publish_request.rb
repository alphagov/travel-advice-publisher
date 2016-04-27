class PublishRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :edition_id
  field :request_id
  field :check_count, type: Integer, default: 0
  field :succeeded, type: Boolean, default: false
  field :checks_complete, type: Boolean, default: false
  field :email_received, type: Boolean, default: false
  field :frontend_updated, type: Boolean, default: false
  field :country_slug, type: String

  MAX_RETRIES = 3

  def self.awaiting_check
    #returns the most recent per country_slug
    #with checks_complete == false
    #and created_at more than 5 minutes ago
    ids = collection.aggregate(
      [
        {
          "$group" => {
            _id: "$country_slug",
            maxCreatedAt: {"$max" => "$created_at"},
            publishRequest: {
              "$last": "$$ROOT"
            }
          }
        },
        {
          "$group" => {
            _id: "$publishRequest._id"
          }
        }
      ]
    ).map{|result| result["_id"]}
    where(:_id.in => ids)
      .where(checks_complete: false)
      .where(:created_at.lt => 5.minutes.ago)
  end

  def register_check_attempt!
    self.check_count = check_count + 1
    self.checks_complete = check_count >= MAX_RETRIES
    if(self.email_received? && self.frontend_updated?)
      self.succeeded = true
      self.checks_complete = true
    end
    save!
  end

  def mark_email_received
    self.email_received = true
  end

  def mark_frontend_updated
    self.frontend_updated = true
  end

  def mark_superseded
    # self.superseded = true
    # self.checks_complete = true
  end
end
