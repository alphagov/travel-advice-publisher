class Admin::SchedulingsController < ApplicationController
  before_action :skip_slimmer
  before_action :load_country_and_edition
  before_action :redirect_unless_can_schedule

  def new; end

  def create
    begin
      @edition.scheduled_publication_time = scheduled_publication_time
      if @edition.save && @edition.schedule_for_publication(current_user)
        redirect_to admin_country_path(@country.slug), notice: "#{@country.name} travel advice is scheduled to publish on #{@edition.scheduled_publication_time.strftime('%B %d, %Y %H:%M %Z')}." and return
      end
    rescue StandardError => e
      @edition.errors.add(:scheduled_publication_time, e)
    end

    flash.now[:alert] = "We had some problems saving: #{@edition.errors.full_messages.join(', ')}."
    render "new"
  end

  def destroy
    if @edition.cancel_schedule_for_publication(current_user)
      redirect_to edit_admin_edition_path(@edition), notice: "Publication schedule cancelled."
    else
      redirect_to edit_admin_edition_path(@edition), alert: "We had some problems cancelling: #{@edition.errors.full_messages.join(', ')}."
    end
  end

private

  def redirect_unless_can_schedule
    redirect_to admin_country_path(@country.slug) unless can_schedule_edition?
  end

  def scheduled_publication_time
    raise StandardError, "cannot be blank" if scheduling_params.values.any?(&:blank?)

    begin
      year, month, day, hour, minute = scheduling_params.to_h.sort.map { |_, v| Integer(v) }
      raise ArgumentError unless year.to_s.match?(/^\d{4}$/) && Date.valid_date?(year, month, day)

      Time.zone.local(year, month, day, hour, minute)
    rescue ArgumentError
      raise StandardError, "is not in the correct format"
    end
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
