class LocationsController < ApplicationController
  before_action :set_location, only: [:show]

  # GET /locations
  def index
    if location_present?
      @spaces = Space.near(params[:location], params[:distance]).paginate(page: params[:page], per_page: 1)
    else
      @spaces = Space.all.paginate(page: params[:page], per_page: 1)
    end
    load_space_markers
  end

  # GET /locations/1
  def show
  end

  private

  def location_present?
    params[:location].present?
  end

  def load_space_markers
    @hash = Gmaps4rails.build_markers(@spaces) do |space, marker|
      marker.lat space.latitude
      marker.lng space.longitude
      marker.infowindow space.address
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_location
    @space = Space.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def location_params
  # params.require(:location).permit(:title, :description, :price, :address, :latitude, :longitude)
  # end
end
