class Admin::SchedulingsController < ApplicationController
  before_action :skip_slimmer

  def new
    @scheduling = Scheduling.new
  end

  def create
    edition = TravelAdviceEdition.find(params[:edition_id])
    scheduled_publish_time = scheduling_params[:scheduled_publish_time]

    @scheduling = Scheduling.new(travel_advice_edition_id: edition, scheduled_publish_time:)
    if @scheduling.save
      @scheduling.schedule_for_publication(edition)

      redirect_to admin_countries_path
    else
      flash[:alert] = "We had some problems saving: #{@scheduling.errors.full_messages.join(', ')}."
      render "new"
    end
  end

private

  def scheduling_params
    params.fetch(:scheduling, {}).permit(
      :scheduled_publish_time,
    )
  end
end
