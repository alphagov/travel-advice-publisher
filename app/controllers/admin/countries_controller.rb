require "gds_api/panopticon"

class Admin::CountriesController < ApplicationController
  def index
    @countries = Country.all
  end

  def show
    @country = Country.find_by_slug(params[:id]) || error_404
  end

  def edit
    @country = Country.find_by_slug(params[:id]) || error_404
    @artefact = Artefact.find_by_slug(params[:id])

    if @artefact.nil?
      flash[:alert] = "Can't edit related content if no draft items present."
      redirect_to(:action => "show", :id => params[:id]) and return
    end

    @related_items = Artefact.all.asc(:name).to_a
  end

  def update
    @country = Country.find_by_slug(params[:id]) || error_404
    artefact = panopticon_api.artefact_for_slug(@country.slug).to_hash
    panopticon_api.put_artefact(@country.slug, artefact.merge(
      "related_items" => params[:related_artefacts].select { |x| !x.empty? }))
    redirect_to admin_country_path
  end

  private

  def panopticon_api
    @panopticon_api ||= GdsApi::Panopticon.new(Plek.current.find("panopticon"),
                                               PANOPTICON_API_CREDENTIALS)
  end
end
