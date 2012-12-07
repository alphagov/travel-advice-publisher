class Admin::DefaultController < ApplicationController
  
  include Admin::AdminControllerMixin

  def index
    render :text => "Test output. Remove this once real specs exist."
  end

end
