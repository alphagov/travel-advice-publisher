class Admin::PartsController < ApplicationController
  before_action :skip_slimmer
  before_action :load_country_and_edition
  before_action :redirect_to_edit_edition_unless_draft_edition, except: %i[review edit]
  layout "design_system"

  def new
    @part = Part.new
  end

  def create
    @part = Part.new(create_params)
    @edition.parts.push(@part)

    if @edition.save
      notifier.put_content(@edition)
      notifier.enqueue
      flash["notice"] = "Part created successfully"

      redirect_to edit_admin_edition_path(@edition)
    else
      render "new"
    end
  end

  def edit
    @part = @edition.parts.find(params[:id])
    redirect_to review_admin_country_edition_part_path(@edition.country_slug, @edition, @part) unless @edition.draft?
  end

  def update
    @part = @edition.parts.find(params[:id])
    @part.assign_attributes(update_params)

    if @edition.save
      notifier.put_content(@edition)
      notifier.enqueue
      flash["notice"] = "Part updated successfully"

      redirect_to edit_admin_edition_path(@edition)
    else
      render "edit"
    end
  end

  def review
    @part = @edition.parts.find(params[:id])
    redirect_to edit_admin_country_edition_part_path(@edition.country_slug, @edition, @part) if @edition.draft?
  end

  def confirm_destroy
    @part = @edition.parts.find(params[:id])
  end

  def destroy
    @part = @edition.parts.find(params[:id])
    @part.destroy!

    notifier.put_content(@edition.reload)
    notifier.enqueue
    flash["notice"] = "Part deleted successfully"

    redirect_to edit_admin_edition_path(@edition)
  end

private

  def load_country_and_edition
    @edition = TravelAdviceEdition.find(params[:edition_id])
    @country = Country.find_by_slug(@edition.country_slug)
  end

  def redirect_to_edit_edition_unless_draft_edition
    unless @edition.draft?
      flash["alert"] = "You cannot add a part to #{@edition.archived? ? 'an' : 'a'} #{@edition.state} edition"
      redirect_to edit_admin_edition_path(@edition)
    end
  end

  def create_params
    update_params.merge(order: @edition.parts.count + 1)
  end

  def update_params
    params
    .require(:part)
    .permit(:title, :body, :slug)
  end

  def notifier
    @notifier ||= PublishingApiNotifier.new
  end
end
