class PublishRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :edition_id
  field :request_id
  field :check_count, type: Integer, default: 0
  field :succeeded, type: Boolean, default: false
  field :checks_complete, type: Boolean, default: false
  field :frontend_updated, type: Boolean, default: false

  MAX_RETRIES = 3

  def register_check_attempt!
    self.check_count = check_count + 1
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
end
