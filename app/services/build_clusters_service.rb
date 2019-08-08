class BuildClustersService
  def initialize(bounds)
    @ar_connection = ActiveRecord::Base.connection
    @bounds        = bounds
  end

  def call
    @clusters_from_db = @ar_connection.execute(query)

    clusters_as_hash
  end

  private

  def query
    <<~QUERY
      SELECT
        ROW_NUMBER() OVER () AS id,
        ARRAY_AGG(id) AS record_ids,
        COUNT( lonlat ) AS number_of_records,
        ST_AsText( ST_Centroid(ST_Collect( lonlat )) ) AS center_coords
      FROM records
      WHERE ST_Contains(ST_MakeEnvelope(#{map_bounds}, 2154), lonlat)
      GROUP BY
          ST_SnapToGrid( ST_SetSRID(lonlat, 2154), #{cluster_size})
      ORDER BY
          number_of_records DESC
    QUERY
  end

  def map_bounds
    @bounds.values.map(&:values).join(', ') # @bounds is a hash of hashes
  end

  def cluster_size
    map_with_in_degrees = @bounds['nw']['lng'] - @bounds['se']['lng'] # north west longitude - south east longitude

    map_with_in_degrees.fdiv(6).round(3) # cluster radius is 1/4 of displayed map
  end

  def clusters_as_hash
    @clusters_from_db.map do |cluster|
      center_coords = RGeo::Geos.factory.parse_wkt(cluster['center_coords']).coordinates
      record_ids    = cluster['record_ids'].tr('{},', ' ').split.map(&:to_i) # original = "{123, 1414, 313, ...}"

      {
        id:                cluster['id'], # id of cluster based on row number
        ids:               record_ids,    # ids of the clustered records
        number_of_records: cluster['number_of_records'],
        position:          { lng: center_coords[0], lat: center_coords[1] } # fits gmaps API syntax
      }
    end
  end
end
