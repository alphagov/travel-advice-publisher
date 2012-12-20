class Admin::CountriesController < ApplicationController
  include Admin::AdminControllerMixin

  def index
    @countries = Country.all
  end
end
