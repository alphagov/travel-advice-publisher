class Admin::CountriesController < ApplicationController

  def index
    @countries = Country.all
  end

  def show
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
