class Admin::CountriesController < ApplicationController
  layout :get_layout
  before_action :skip_slimmer
  before_action :load_country, only: [:show]

  def index
    @countries = Country.all
    render "admin/countries/index_legacy" if is_legacy_layout?
  end

  def show; end

private

  def is_legacy_layout?
    !preview_design_system_user?
  end

  def get_layout
    return "legacy" if is_legacy_layout? || %(show).include?(action_name)

    "design_system"
  end

  def load_country
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
