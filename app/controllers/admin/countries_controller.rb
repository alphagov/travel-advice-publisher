class Admin::CountriesController < ApplicationController
  include Admin::AdminControllerMixin

  def index
    @countries = Country.all
  end

  def show
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
