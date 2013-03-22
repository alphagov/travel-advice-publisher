require "gds_api/panopticon"

class Admin::CountriesController < ApplicationController
  before_filter :load_country, :only => [:show, :edit, :update]

  def index
    @countries = Country.all
  end

  def show
  end

  def edit
    @global_related_artefacts = Artefact.find_by_slug("foreign-travel-advice").related_artefacts
    @artefact = Artefact.find_by_slug(artefact_slug_for_country(params[:id]))

    if @artefact.nil?
      flash[:alert] = "Can't edit related content if no draft items present."
      redirect_to(:action => "show", :id => params[:id]) and return
    end

    @related_items = Artefact.relatable_items
  end

  def update
    country_slug = artefact_slug_for_country(@country.slug)
    panopticon_api.put_artefact(country_slug,
      "related_artefact_ids" => params[:related_artefacts].select { |x| x.present? })
    redirect_to admin_country_path
  end

  private

  def panopticon_api
    @panopticon_api ||= GdsApi::Panopticon.new(Plek.current.find("panopticon"),
                                               CONTENT_API_CREDENTIALS)
  end

  def artefact_slug_for_country(country)
    "foreign-travel-advice/#{country}"
  end

  def load_country
    @country = Country.find_by_slug(params[:id]) || error_404
  end
end
