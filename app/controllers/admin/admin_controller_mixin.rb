module Admin::AdminControllerMixin
  def self.included(base)
    base.send :include, GDS::SSO::ControllerMethods

    base.before_filter :authenticate_user!
    base.before_filter :require_signin_permission!
  end
end
