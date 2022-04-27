class Admin::CountriesController < ApplicationController
  layout :get_layout
  before_action :skip_slimmer
  before_action :load_country, only: [:show]

  def index
    @countries = Country.all
    render "admin/countries/index_legacy" if is_legacy_layout?
  end

  def show
    render "admin/countries/show_legacy" if is_legacy_layout?
  end

private

  def load_country
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
