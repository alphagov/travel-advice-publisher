class PublishRequest
  include Mongoid::Document
  include Mongoid::Timestamps

  field :edition_id
  field :request_id
end
