require "digest/md5"
require "cgi"
require "gds-sso/user"
require_dependency "safe_html"

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include GDS::SSO::User

  store_in collection: "travel_advice_publisher_users"

  field "name",                    type: String
  field "uid",                     type: String
  field "version",                 type: Integer
  field "email",                   type: String
  field "permissions",             type: Array
  field "remotely_signed_out",     type: Boolean, default: false
  field "organisation_slug",       type: String
  field "disabled",                type: Boolean, default: false
  field "organisation_content_id", type: String

  index({ uid: 1 }, unique: true)
  index disabled: 1

  scope :alphabetized, lambda { order_by(name: :asc) }
  scope :enabled, lambda {
    any_of({ :disabled.exists => false },
           { :disabled.in => [false, nil] }) # rubocop:disable Style/BracesAroundHashParameters
  }

  def to_s
    name || email || ""
  end

  def gravatar_url(opts = {})
    opts.symbolize_keys!
    "%s.gravatar.com/avatar/%s%s" % [
      opts[:ssl] ? "https://secure" : "http://www",
      Digest::MD5.hexdigest(email.downcase),
      opts[:s] ? "?s=#{CGI.escape(opts[:s])}" : "",
    ]
  end
end
