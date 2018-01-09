class LinkCheckReportsController < ApplicationController
  before_action :find_edition

  def create
    service = LinkCheckReportCreator.new(
      travel_advice_edition_id: @edition.id
    )

    @report = service.call

    respond_to do |format|
      format.js { render "admin/link_check_reports/create" }
      format.html { redirect_to edit_admin_edition_url(@edition.id) }
    end
  end

private

  def find_edition
    @edition = TravelAdviceEdition.find(params[:edition_id])
  end
end
