module Healthcheck
  class Mongoid
    def name
      :database_connectivity
    end

    def status
      ::Mongoid.default_client.database_names.present?
      GovukHealthcheck::OK
    rescue StandardError
      GovukHealthcheck::CRITICAL
    end
  end
end
