class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods
  before_filter :authenticate_user!
  before_filter :require_signin_permission!

  def error_404; error 404; end

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end
end
