require_dependency "safe_html"

class Action
  include Mongoid::Document

  STATUS_ACTIONS = [
    CREATE                      = "create",
    REQUEST_REVIEW              = "request_review",
    APPROVE_REVIEW              = "approve_review",
    APPROVE_FACT_CHECK          = "approve_fact_check",
    REQUEST_AMENDMENTS          = "request_amendments",
    SEND_FACT_CHECK             = "send_fact_check",
    RECEIVE_FACT_CHECK          = "receive_fact_check",
    SKIP_FACT_CHECK             = "skip_fact_check",
    SCHEDULE_FOR_PUBLISHING     = "schedule_for_publishing",
    CANCEL_SCHEDULED_PUBLISHING = "cancel_scheduled_publishing",
    PUBLISH                     = "publish",
    ARCHIVE                     = "archive",
    NEW_VERSION                 = "new_version",
  ]

  NON_STATUS_ACTIONS = [
    NOTE                 = "note",
    IMPORTANT_NOTE       = "important_note",
    IMPORTANT_NOTE_RESOLVED = "important_note_resolved",
    ASSIGN               = "assign",
  ]

  embedded_in :edition

  belongs_to :recipient, class_name: "User"
  belongs_to :requester, class_name: "User"

  field :approver_id,        type: Integer
  field :approved,           type: DateTime
  field :comment,            type: String
  field :comment_sanitized,  type: Boolean, default: false
  field :request_type,       type: String
  field :request_details,    type: Hash, default: {}
  field :email_addresses,    type: String
  field :customised_message, type: String
  field :created_at,         type: DateTime, default: lambda { Time.zone.now }

  def container_class_name(edition)
    edition.container.class.name.underscore.humanize
  end

  def status_action?
    STATUS_ACTIONS.include?(request_type)
  end

  def to_s
    if request_type == SCHEDULE_FOR_PUBLISHING
      string = "Scheduled for publishing"
      string += " on #{request_details['scheduled_time'].to_datetime.in_time_zone('London').strftime('%d/%m/%Y %H:%M')}" if request_details['scheduled_time'].present?
      string
    else
      request_type.humanize.capitalize
    end
  end

  def is_fact_check_request?
    # SEND_FACT_CHECK is now a state - in older publications it isn't
    request_type == SEND_FACT_CHECK || request_type == "fact_check_requested"
  end
end
