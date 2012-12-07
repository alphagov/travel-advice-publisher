require 'spec_helper'

# TODO: Remove this spec once real specs exist. This is just for CI. 
#
describe Admin::DefaultController do
  
  before do
    GDS::SSO.test_user = FactoryGirl.create(:user)
  end

  it "should display some test text" do
    visit "/admin"
    response.should be_success
    page.should have_content "Test output. Remove this once real specs exist."
  end

end
