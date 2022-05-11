module AuthenticationHelpers
  def stub_user
    create(:user)
  end

  def login_as_stub_user
    login_as stub_user
  end

  def login_as_stub_user_with_design_system_permission
    login_as stub_user_with_design_system_permission
  end

  def stub_user_with_design_system_permission
    create(:user, :with_design_system_permission)
  end
end
RSpec.configuration.include AuthenticationHelpers, type: :controller
RSpec.configuration.include AuthenticationHelpers, type: :feature

module AuthenticationHelpers::ControllerHelpers
  def login_as(user)
    request.env["warden"] = double(
      authenticate!: true,
      authenticated?: true,
      user: user,
    )
  end
end
RSpec.configuration.include AuthenticationHelpers::ControllerHelpers, type: :controller

module AuthenticationHelpers::FeatureHelpers
  def login_as(user)
    GDS::SSO.test_user = user
  end
end
RSpec.configuration.include AuthenticationHelpers::FeatureHelpers, type: :feature