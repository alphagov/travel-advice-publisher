class Admin::EditionsController < ApplicationController

  before_filter :load_country, :only => [:create]

  def create
    @edition = @country.build_new_edition
    if @edition.save
      redirect_to edit_admin_edition_path(@edition)
    else
      redirect_to admin_country_path(@country.slug), :alert => "Failed to create new edition"
    end
  end

  def edit
    @edition = TravelAdviceEdition.find(params[:id])
    @country = Country.find_by_slug(@edition.country_slug)
  end

  def update
    @edition = TravelAdviceEdition.find(params[:id])
    if @edition.update_attributes(params[:edition])
      redirect_to edit_admin_edition_path(@edition), :alert => "Edition updated"
    else
      redirect_to edit_admin_edition_path(@edition), :alert => "Failed to update edition"
    end
  end

  private

  def load_country
    @country = Country.find_by_slug(params[:country_id])
    error_404 unless @country
  end
end
