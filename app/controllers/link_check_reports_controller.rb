class LinkCheckReportsController < ApplicationController
  before_action :find_edition

  def create
    service = LinkCheckReportCreator.new(
      travel_advice_edition_id: @edition.id,
    )

    @report = service.call

    redirect_to edit_admin_edition_url(@edition.id)
  end

  def show
    @report = @edition.link_check_reports.find_by(id: params[:id])

    redirect_to edit_admin_edition_url(@edition.id)
  end

private

  def find_edition
    @edition = TravelAdviceEdition.find(params[:edition_id])
  end
end
