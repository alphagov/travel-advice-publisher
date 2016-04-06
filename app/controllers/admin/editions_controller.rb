class Admin::EditionsController < ApplicationController

  before_filter :load_country, :only => [:create]
  before_filter :load_country_and_edition, :only => [:edit, :update, :destroy, :diff]
  before_filter :strip_empty_alert_statuses, :only => :update

  def create
    if params[:edition_version].nil?
      edition = @country.build_new_edition_as(current_user)
    else
      old_edition = @country.editions.where(:version_number => params[:edition_version]).first
      edition = @country.build_new_edition_as(current_user, old_edition)
    end

    if edition.save
      notifier.put_content(edition)
      notifier.put_links(edition)
      notifier.enqueue
      redirect_to edit_admin_edition_path(edition)
    else
      redirect_to admin_country_path(@country.slug), :alert => "Failed to create new edition"
    end
  end

  def diff
    @comparison = @country.editions.find(params[:compare_id])
  end

  def edit
  end

  def destroy
    country_slug = @edition.country_slug
    if @edition.draft?
      if @edition.destroy
        redirect_to admin_country_path(country_slug, :alert => "Edition deleted")
      else
        redirect_to admin_country_path(country_slug, :alert => "Failed to delete draft edition")
      end
    else
      redirect_to edit_admin_edition_path(@edition, :alert => "Can't delete a published or archived edition")
    end
  end

  def update
    case params[:commit]
    when "Update review date"
      update_review_date
    when "Save"
      save
    when "Save & Publish"
      save_and_publish
    when "Add Note"
      add_note
    else
      raise ArgumentError, "params[:commit] is not recognised: #{params[:commit].inspect}"
    end
  end

  private
  def permitted_edition_attributes
    params[:edition].permit(
      :minor_update,
      :change_description,
      :title,
      :overview,
      :csv_synonyms,
      :summary,
      :note,
      :image,
      :document,
      :remove_document,
      :remove_image,
      alert_status: [],
      parts_attributes: [:title, :body, :slug, :order, :id, :_destroy]
    )
  end

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

  def save_and_publish
    if @edition.update_attributes(permitted_edition_attributes) && @edition.publish_as(current_user)
      notifier.put_content(@edition)
      notifier.put_links(@edition)
      notifier.publish(@edition)
      notifier.send_alert(@edition)
      notifier.enqueue

      index_notifier = PublishingApiNotifier.new
      index_notifier.publish_index
      index_notifier.enqueue

      # catch any upload errors
      if @edition.errors.any?
        flash[:alert] = @edition.errors.full_messages.join(", ")
      end

      redirect_to admin_country_path(@edition.country_slug), :alert => "#{@edition.title} published."
    else
      flash[:alert] = "We had some problems publishing: #{@edition.errors.full_messages.join(", ")}."
      render "/admin/editions/edit"
    end
  end

  def save(&block)
    if @edition.update_attributes(permitted_edition_attributes)
      notifier.put_content(@edition)
      notifier.enqueue

      block.call and return if block_given?

      # catch any upload errors
      if @edition.errors.any?
        flash[:alert] = @edition.errors.full_messages.join(", ")
      end

      redirect_to edit_admin_edition_path(@edition), :alert => "#{@edition.title} updated."
    else
      flash[:alert] = "We had some problems saving: #{@edition.errors.full_messages.join(", ")}."
      render "/admin/editions/edit"
    end
  end

  def update_review_date
    @edition.reviewed_at = Time.zone.now.utc

    if @edition.save!
      notifier.put_content(@edition)
      notifier.publish(@edition, update_type: "minor")
      notifier.enqueue
      redirect_to admin_country_path(@edition.country_slug), :alert => "Updated review date"
    else
      redirect_to edit_admin_edition_path(@edition), :alert => "Failed to update the review date"
    end
  end

  def add_note
    @edition.build_action_as(current_user, Action::NOTE, params[:edition][:note][:comment])
    save
  end

  def notifier
    @notifier ||= PublishingApiNotifier.new
  end
end
