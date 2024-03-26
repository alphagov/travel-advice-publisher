class Admin::SchedulingsController < ApplicationController
  before_action :skip_slimmer
  before_action :load_country_and_edition, only: %i[new create destroy]
  before_action :redirect_unless_can_schedule

  def new; end

  def create

    if datetime_input_errors.empty?
      squashed_params = squash_multiparameter_scheduled_publication_time_attribute(scheduling_params)
      @edition.scheduled_publication_time = squashed_params[:scheduled_publication_time]

      if @edition.save && @edition.schedule_for_publication(current_user)
        redirect_to admin_country_path(@country.slug), notice: "#{@country.name} travel advice is scheduled to publish on #{@edition.scheduled_publication_time.strftime('%B %d, %Y %H:%M %Z')}."
      else
        flash.now[:alert] = "We had some problems saving: #{@edition.errors.full_messages.join(', ')}."
        render "new"
      end
    else
      @edition.errors.delete(:scheduled_publication_time)
      @edition.errors.add(:scheduled_publication_time, datetime_input_errors[:scheduled_publication_time])
      flash.now[:alert] = "We had some problems saving: #{@edition.errors.full_messages.join(', ')}."
      render "new"
    end
  end

  def destroy
    if @edition.cancel_schedule_for_publication(current_user)
      redirect_to edit_admin_edition_path(@edition), notice: "Publication schedule cancelled."
    else
      redirect_to edit_admin_edition_path(@edition), alert: "We had some problems cancelling: #{@edition.errors.full_messages.join(', ')}."
    end
  end

private

  def squash_multiparameter_scheduled_publication_time_attribute(params)
    datetime_params = scheduling_params.to_h.sort.map { |_, v| v.to_i }
    params.delete_if { |k, _| k.include? "scheduled_publication_time" }
    params[:scheduled_publication_time] = Time.zone.local(*datetime_params) if datetime_params.present?
    params
  end

  def redirect_unless_can_schedule
    redirect_to admin_country_path(@country.slug) and return unless can_schedule_edition?
  end

  def datetime_input_errors
    errors = {}
    year, month, day, hour, minute = scheduling_params.to_h.sort.map { |_, v| v }

    return errors.merge!({ scheduled_publication_time: "cannot be blank" }) if [year, month, day].all?(&:blank?)
    return errors.merge!({ scheduled_publication_time: "is not in the correct format" }) unless year.match?(/^\d{4}$/) && month.match?(/^\d{1,2}$/) && day.match?(/^\d{1,2}$/) \
      && hour.match?(/^\d{1,2}$/) && minute.match?(/^\d{1,2}$/)

    begin
      Time.zone.local(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
    rescue ArgumentError
      return errors.merge!({ scheduled_publication_time: "is not in the correct format" })
    end

    errors
  end

  def scheduling_params
    params.fetch(:scheduling, {}).permit(
      :scheduled_publication_time,
    )
  end

  def load_country_and_edition
    @edition = TravelAdviceEdition.find(params[:edition_id])
    @country = Country.find_by_slug(@edition.country_slug)
  end
end
