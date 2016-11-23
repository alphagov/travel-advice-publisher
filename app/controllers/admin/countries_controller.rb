class Admin::CountriesController < ApplicationController
  before_filter :skip_slimmer
  before_filter :load_country, :only => [:show]

  def index
    @countries = Country.all
  end

  def show
  end

  private

  def artefact_slug_for_country(country)
    "foreign-travel-advice/#{country}"
  end

  def load_country
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
