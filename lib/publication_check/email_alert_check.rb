module PublicationCheck
  class EmailAlertCheck
    attr_reader :govuk_request_id, :publish_request

    def run(publish_request)
      @publish_request = publish_request
      @govuk_request_id = publish_request.request_id
      run_check
    end

  private

    def run_check
      begin
        get_object
        publish_request.mark_email_received
        return true
      rescue Aws::S3::Errors::NoSuchKey
        return false
      end
    end

    def get_object
      s3.get_object(
        bucket: bucket,
        key: object_key
      )
    end

    def bucket
      "govuk-email-alert-notifications"
    end

    def object_key
      "travel-advice-alerts/#{govuk_request_id}.msg"
    end

    def s3
      @s3 ||= Aws::S3::Client.new
    end
  end
end
