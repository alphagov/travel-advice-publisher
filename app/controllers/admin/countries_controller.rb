class Admin::CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.find_by_slug(params[:id]) || error_404
  end

  def edit
    @country = Country.find_by_slug(params[:id]) || error_404
    @related_items = [OpenStruct.new(:id => 1, :name => "A thing"),
                      OpenStruct.new(:id => 2, :name => "Another thing")]
  end

  def update
    @country = Country.find_by_slug(params[:id]) || error_404
    redirect_to admin_country_path
  end
end
