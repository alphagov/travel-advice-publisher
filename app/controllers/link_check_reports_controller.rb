class LinkCheckReportsController < ApplicationController
  before_action :find_reportable

  def create
    service = LinkCheckReportCreator.new(
      travel_advice_edition_id: @reportable
    )

    @report = service.call

    respond_to do |format|
      format.js { render 'link_check_reports/create' }
      format.html { redirect_to edit_admin_edition_url(@reportable.id) }
    end
  end

private

  def find_reportable
    @reportable = TravelAdviceEdition.find(params[:travel_advice_edition_id])
  end
end
