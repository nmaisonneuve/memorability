class Pano < ActiveRecord::Base
  #set_rgeo_factory_for_column(:latlng, RGeo::Geos.factory(srid: 4326))

  attr_accessible :panoID, :image_date, :yaw_deg, :original_latlng, :latlng, :elevation, :description, :street, :region, :country, :raw_json, :links, :processed_at,:num_zoom_level, :selected, :label

  has_many :rays
  has_many :visible_rays
  has_many :povs

  RAD2DEG = 180.0 / Math::PI
  DEG2RAD = Math::PI / 180.0
  # image width x height
  WIDTH = 6656.0
	HEIGHT = 3330.0

  def lat
  	latlng.y
  end

  def lng
  	latlng.x
  end

  class Block
    def initialize()
      @reversed = false
    end

    def min_ray
      Ray.find(@min)
    end

    def max_ray
      Ray.find(@max)
    end

    def reverse
      @min = nil
      @reversed = true
    end

    def add (id)
      @min = id  if @min.nil?
      @max = id unless @reversed
    end

    def to_s
    "#{@min} #{@max} (reversed: #{@reversed}"
    end

  end

  def building_povs
    current_building = nil
    # order by building , order by ray_id
    buildings = {}
    block = Block.new
    visible_rays.each do |vr|
      unless vr.facade.nil?
        if current_building != vr.facade.building_id
          current_building = vr.facade.building_id
          if buildings.has_key?(current_building) # already existing
            buildings[current_building].reverse
          else
            buildings[current_building] = Block.new
          end
        end
        buildings[current_building].add(vr.ray_id)
        # puts "#{vr.ray_id} - #{vr.facade.building_id}"
      else
        current_building = nil
      end
    end
       buildings.each do |k,v|
        Ray.find(v)
       # Pov.create(pano_id: self.id, v.min_ray.id, v[:max], "POLYGON(LINESTRING(# {lng} #{lat}, #{min_ray.lng min_ray.lat} #{max_ray.lat max_ray.lng})" )
       #  p v
       end
  end

  def cutting_from_pixels(pixel1, pixel2)
	  width = pixel2 - pixel1
	  start = pixel1
	  if (width > 0)
	  	start = pixel2
	  	width = -width
	  end
	  cmd = "convert pano-#{panoID}.jpg  -crop #{width}x#{HEIGHT}+#{start}+0  building-#{panoID}_cut.jpg"
	 	Subexec.run cmd, :timeout => 0
	end

  def cutting_from_angles(angle1, angle2)
  	pixel1 = angle_to_pixel(angle1)
  	pixel2 = angle_to_pixel(angle2)
		cutting_from_pixels(pixel1, pixel2)
  end

  # angle from [-180 to 180]
  # 0 to 260
  def pixel_to_angle(pixel)

    pixel_center = WIDTH.to_f/2.0

    relative_pixel = pixel - pixel_center

    relative_angle = relative_pixel * pixel_center / 180.0

    absolute_angle = ((360.0 - YAWDEG + relative_angle) % 360)

    absolute_angle
  end

  # angle from [-180 to 180]
  # 0 to 260
  def angle_to_pixel(angle)
  	# cutoff if required
  	angle = 180 if angle >180
  	angle = -180 if angle < -180

  	# angle = 180 ->
  	ratio = (angle - yaw_deg + 180.0)/360.0
  	WIDTH * ratio
  end

  def generate_ray(relative_angle, distance_meter)
  	absolute_angle = (( yaw_deg + 0 + relative_angle) % 360) * DEG2RAD #
    lat1 =  DEG2RAD * lat
    lng1 =  DEG2RAD * lng
    d_rad = distance_meter.to_f / 6378137.0

    lat2 = Math::asin(Math::sin(lat1) * Math::cos(d_rad) + Math::cos(lat1)* Math::sin(d_rad)* Math::cos(absolute_angle))
    lng2  = lng1 + Math::atan2(Math::sin(absolute_angle) * Math::sin(d_rad) * Math::cos(lat1), Math::cos(d_rad) - Math::sin(lat1) * Math::sin(lat2))

    end_point = [lng2 * RAD2DEG, lat2 * RAD2DEG]
    # LINESTRING (Lon Lat)
		geom_string = "LINESTRING(#{lng} #{lat}, #{end_point[0]} #{end_point[1]} )"
    self.rays << Ray.new(angle: relative_angle, geom: geom_string, pano_id:self.id )
    self.rays
  end

end