require 'spec_helper'

# TODO: Remove this spec once real specs exist. This is just for CI. 
#
describe Admin::DefaultController do
  
  before do
    GDS::SSO.test_user = FactoryGirl.create(:user)
  end

  it "should display some test text" do
    visit "/"
    page.body.should == "Test output. Remove this once real specs exist."
  end

end
