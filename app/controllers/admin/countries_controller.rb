require "gds_api/panopticon"

class Admin::CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.find_by_slug(params[:id]) || (error_404 and return)
  end

  def edit
    @country = Country.find_by_slug(params[:id]) || (error_404 and return)
    @global_related_artefacts = Artefact.find_by_slug("foreign-travel-advice").related_artefacts
    @artefact = Artefact.find_by_slug(artefact_slug_for_country(params[:id]))

    if @artefact.nil?
      flash[:alert] = "Can't edit related content if no draft items present."
      redirect_to(:action => "show", :id => params[:id]) and return
    end

    @related_items = Artefact.all.asc(:name).to_a
  end

  def update
    @country = Country.find_by_slug(params[:id]) || (error_404 and return)
    country_slug = artefact_slug_for_country(@country.slug)
    artefact = panopticon_api.artefact_for_slug(country_slug).to_hash
    panopticon_api.put_artefact(country_slug, artefact.merge(
      "related_artefact_ids" => params[:related_artefacts].select { |x| x.present? }))
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
end
