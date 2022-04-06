class ApplicationController < ActionController::Base
  protect_from_forgery

  include GDS::SSO::ControllerMethods
  before_action :authenticate_user!
  before_action :set_authenticated_user_header

  def error_404
    error 404
  end

private

  helper_method :preview_design_system_user?

  def preview_design_system_user?
    current_user.has_permission? "Preview Design System"
  end

  def error(status_code)
    render status: status_code, plain: "#{status_code} error"
  end

  def set_authenticated_user_header
    if current_user && GdsApi::GovukHeaders.headers[:x_govuk_authenticated_user].nil?
      GdsApi::GovukHeaders.set_header(:x_govuk_authenticated_user, current_user.uid)
    end
  end

  def skip_slimmer
    response.headers[Slimmer::Headers::SKIP_HEADER] = "true"
  end
end
