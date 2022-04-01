class Admin::CountriesController < ApplicationController
  layout :get_layout
  before_action :skip_slimmer
  before_action :load_country, only: [:show]

  def index
    @countries = Country.all
  end

  def show; end

private

  def get_layout
    if action_name == "show"
      "design_system"
    else
      "legacy"
    end
  end

  def load_country
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
