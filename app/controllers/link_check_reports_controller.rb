class LinkCheckReportsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :require_signin_permission!

  def create
    service = LinkCheckReportCreator.new(
      travel_advice_edition_id: link_reportable_params[:travel_advice_edition_id]
    )

    service.call

    head :created
  end

private

  def link_reportable_params
    params.require(:link_reportable).permit(:travel_advice_edition_id)
  end
end
