class Admin::EditionsController < ApplicationController

  before_filter :load_country, :only => [:create]
  before_filter :load_country_and_edition, :only => [:edit, :update]
  before_filter :strip_empty_alert_statuses, :only => :update

  def create
    if params[:edition_version].nil?
      edition = @country.build_new_edition_as(current_user)
    else
      unless @country.editions.where(:state => "draft").size >= 1
        old_edition = @country.editions.where(:version_number => params[:edition_version]).first
        edition = @country.build_new_edition_as(current_user, old_edition)
      end
    end

    if !edition.nil? && edition.save
      redirect_to edit_admin_edition_path(edition)
    else
      redirect_to admin_country_path(@country.slug), :alert => "Failed to create new edition"
    end
  end

  def edit
    @draft_exists = @country.has_draft_edition?
  end

  def update
    if params[:edition][:note] && params[:edition][:note][:comment] && !params[:edition][:note][:comment].empty?
      @edition.build_action_as(current_user, Action::NOTE, params[:edition][:note][:comment])
    end

    if @edition.update_attributes(params[:edition])
      if params[:commit] == "Save & Publish"
        if @edition.publish_as(current_user)
          redirect_to admin_country_path(@edition.country_slug), :alert => "#{@edition.title} published."
        else
          flash[:alert] = "We had some problems publishing: #{@edition.errors.full_messages.join(", ")}."
          render "/admin/editions/edit"
        end
      else
        redirect_to edit_admin_edition_path(@edition), :alert => "#{@edition.title} updated."
      end
    else
      flash[:alert] = "We had some problems saving: #{@edition.errors.full_messages.join(", ")}."
      render "/admin/editions/edit"
    end
  end

  private

  def load_country_and_edition
    @edition = TravelAdviceEdition.find(params[:id])
    @country = Country.find_by_slug(@edition.country_slug)
  end

  def load_country
    @country = Country.find_by_slug(params[:country_id])
    error_404 unless @country
  end

  def strip_empty_alert_statuses
    if params[:edition] and params[:edition][:alert_status]
      params[:edition][:alert_status].reject!(&:blank?)
    end
  end
end
