require 'country'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods

  def error_404; error 404; end

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end
end
