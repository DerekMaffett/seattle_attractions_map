class MapsController < ApplicationController
  skip_before_action :authenticate_admin!

  def map
    params[:location] ||= ''
    if params[:location] == ''
      @attractions = Attraction.alphabetize
      @map_center = { lat: 47.618615, lng: -122.338470, zoom: 13 }
      @attractions = Attraction.alphabetize
    else
      location = Location.find_by(name: params[:location])
      @map_center = {
        lat: location.latitude,
        lng: location.longitude,
        zoom: location.zoom
      }
      @attractions = location.attractions.alphabetize
    end
    @markers_hash =
      build_json_hash(@attractions + ParkingLot.all + Restaurant.all).to_json
    @locations = Location.all
  end

  private

  def build_json_hash(locations)
    Gmaps4rails.build_markers(locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
      marker.json(id: location.id)
      marker.picture('url' => ActionController::Base.helpers.asset_path(find_marker(location), type: :image),
                     'width' =>  30,
                     'height' => 30)
      marker.infowindow render_to_string(partial: find_partial(location), locals: { location: location })
    end
  end

  def find_partial(location)
    case location.class.to_s
    when 'Attraction' then 'attractions/info_window'
    when 'ParkingLot' then 'parking_lots/info_window'
    when 'Restaurant' then 'restaurants/info_window'
    end
  end

  def find_marker(location)
    case location.class.to_s
    when 'Attraction' then 'attractionmarkersm.png'
    when 'ParkingLot' then 'parkingmarkerdark.png'
    when 'Restaurant' then 'restaurantred.png'
    end
  end
end
