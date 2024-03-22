require_dependency "safe_html"

class Action
  include Mongoid::Document

  STATUS_ACTIONS = [
    CREATE = "create".freeze,
    SCHEDULE_FOR_PUBLICATION = "schedule_for_publication".freeze,
    PUBLISH                     = "publish".freeze,
    NEW_VERSION                 = "new_version".freeze,
    CANCEL_SCHEDULE             = "cancel_schedule".freeze,
  ].freeze

  NON_STATUS_ACTIONS = [
    NOTE = "note".freeze,
  ].freeze

  embedded_in :edition

  belongs_to :recipient, class_name: "User", optional: true
  belongs_to :requester, class_name: "User"

  field :approver_id,        type: Integer
  field :approved,           type: DateTime
  field :comment,            type: String
  field :comment_sanitized,  type: Boolean, default: false
  field :request_type,       type: String
  field :request_details,    type: Hash, default: {}
  field :email_addresses,    type: String
  field :customised_message, type: String
  field :created_at,         type: DateTime, default: -> { Time.zone.now }

  def status_action?
    STATUS_ACTIONS.include?(request_type)
  end

  def to_s
    if request_type == SCHEDULE_FOR_PUBLICATION
      string = "Schedule for publication"
      string += " on #{request_details['scheduled_publication_time'].strftime('%B %d, %Y %H:%M %Z')}" if request_details["scheduled_publication_time"].present?
      string
    else
      request_type.humanize.capitalize
    end
  end

  def requester_is_a_robot?
    requester.uid == "scheduled_publishing_robot"
  end
end
