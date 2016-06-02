class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods
  before_filter :authenticate_user!
  before_filter :require_signin_permission!
  before_filter :set_authenticated_user_header

  def error_404; error 404; end

  private

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end
end
