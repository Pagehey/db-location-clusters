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
          ST_SnapToGrid( ST_SetSRID(lonlat, 2154), #{cluster_radius})
      ORDER BY
          number_of_records DESC
    QUERY
  end

  def map_bounds
    @bounds.values.map(&:values).join(', ') # @bounds is a hash of hashes
  end

  def cluster_radius
    map_with_in_degrees = @bounds['nw']['lng'] - @bounds['se']['lng'] # north west longitude - south east longitude

    map_with_in_degrees.fdiv(4).round(3) # cluster radius is 1/4 of displayed map
  end

  def clusters_as_hash
    @clusters_from_db.map do |cluster|
      center_coords = RGeo::Geos.factory.parse_wkt(cluster['center_coords']).coordinates
      record_ids    = cluster['record_ids'].tr('{},', ' ').split.map(&:to_i).first 3

      {
        id:        cluster['id'],                # id of cluster based on row number
        ids:       record_ids,                   # ids of the clustered records (current format is String: "{123, 1414, 313, ...}")
        reference: cluster['number_of_records'], # is named 'reference' to match record objects for gmaps vue component
        position:  { lng: center_coords[0], lat: center_coords[1] } # fits gmaps API syntax
      }
    end
  end
end
