class BuildClustersServiceBis
  def initialize(bounds)
    @ar_connection = ActiveRecord::Base.connection
    @bounds        = bounds
  end

  def call
    ClusterSerializer.render_as_hash(clusters)
  end

  private

  def clusters
    Record.select( # they are not records though ...
      'row_number() over () AS id,
        array_agg(id) AS record_ids,
        COUNT( lonlat ) AS number_of_records,
        ST_Centroid(ST_Collect( lonlat )) AS center_coords'
    ).
    where("ST_Contains(ST_MakeEnvelope(#{map_bounds}, 2154), lonlat)").
    group("ST_SnapToGrid( ST_SetSRID(lonlat, 2154), #{cluster_radius})").
    order('number_of_records DESC')
  end

  def map_bounds
    @bounds.values.map(&:values).join(', ') # @bounds is a hash of hashes
  end

  def cluster_radius
    map_with_in_degrees = @bounds['nw']['lng'] - @bounds['se']['lng'] # north west longitude - south east longitude

    map_with_in_degrees.fdiv(4).round(3).to_s # cluster radius is 1/4 of displayed map
  end
end
