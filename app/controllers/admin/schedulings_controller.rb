class Admin::SchedulingsController < ApplicationController
  before_action :skip_slimmer
  before_action :load_country_and_edition, only: %i[new create]

  def new
    redirect_to admin_country_path(@country.slug) and return unless can_schedule_edition?

    @scheduling = Scheduling.new
  end

  def create
    redirect_to admin_country_path(@country.slug) and return unless can_schedule_edition?

    if has_valid_datetime_input_values?
      squashed_params = squash_multiparameter_scheduled_publish_time_attribute(scheduling_params)
      @scheduling = Scheduling.new(travel_advice_edition: @edition, scheduled_publish_time: squashed_params[:scheduled_publish_time])

      if @scheduling.save && @edition.schedule_as(current_user)
        @scheduling.schedule_for_publication(@edition)
        redirect_to admin_country_path(@country.slug), notice: "#{@country.name} travel advice is scheduled to publish on #{@edition.scheduling.scheduled_publish_time.strftime('%B %d, %Y %H:%M %Z')}."
      else
        flash.now[:alert] = "We had some problems saving: #{@scheduling.errors.full_messages.join(', ')}."
        render "new"
      end
    else
      @scheduling = Scheduling.new(travel_advice_edition: @edition, scheduled_publish_time: nil)
      @scheduling.errors.delete(:scheduled_publish_time)
      @scheduling.errors.add(:scheduled_publish_time, "format is invalid")
      flash.now[:alert] = "We had some problems saving: #{@scheduling.errors.full_messages.join(', ')}."
      render "new"
    end
  end

private

  def squash_multiparameter_scheduled_publish_time_attribute(params)
    datetime_params = scheduling_params.to_h.sort.map { |_, v| v.to_i }
    params.delete_if { |k, _| k.include? "scheduled_publish_time" }
    params[:scheduled_publish_time] = Time.zone.local(*datetime_params) if datetime_params.present?

    params
  end

  def has_valid_datetime_input_values?
    year, month, day, hour, minute = scheduling_params.to_h.sort.map { |_, v| v }
    return false unless year.match?(/^\d{4}$/) && month.match?(/^\d{1,2}$/) && day.match?(/^\d{1,2}$/) \
      && hour.match?(/^\d{1,2}$/) && minute.match?(/^\d{1,2}$/)

    begin
      Time.zone.local(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
    rescue ArgumentError
      return false
    end
    true
  end

  def scheduling_params
    params.fetch(:scheduling, {}).permit(
      :scheduled_publish_time,
    )
  end

  def load_country_and_edition
    @edition = TravelAdviceEdition.find(params[:edition_id])
    @country = Country.find_by_slug(@edition.country_slug)
  end
end
