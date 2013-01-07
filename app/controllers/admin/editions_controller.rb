class Admin::EditionsController < ApplicationController

  def new
    @edition = TravelAdviceEdition.new
  end

  def create
    @edition = TravelAdviceEdition.new(params[:edition])
    if @edition.save
      redirect_to admin_editions_path(@edition.to_param), :message => "Successfully created edition."
    else
      render :new
    end
  end
end
