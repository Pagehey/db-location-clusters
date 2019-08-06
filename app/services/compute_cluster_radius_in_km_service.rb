class ComputeClusterRadiusInKmService
  def initialize(bounds)
    @bounds = bounds.deep_symbolize_keys
  end

  def call
    (map_width_in_degrees * width_of_one_degree_at_given_latitude_in_km).fdiv(3).round(3)
  end

  private

  def map_width_in_degrees
    @bounds[:nw][:lng] - @bounds[:se][:lng]
  end

  def width_of_one_degree_at_given_latitude_in_km
    111.320 * Math.cos(radial_latitude) # 1 degree at equator == 111.320km
  end

  def radial_latitude
    @bounds[:nw][:lat] * Math::PI / 180
  end
end




