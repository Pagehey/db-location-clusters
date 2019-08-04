class BuildClustersService
  def initialize(params)
    @radius        = params[:radius]
    @bounds        = JSON.parse params[:bounds]
    @ar_connection = ActiveRecord::Base.connection
  end

  def call
    @clusters_from_db = @ar_connection.execute query
    render_as_hash
  end

  private

  def query
    <<~EOF
      SELECT row_number() over () AS id,
        ST_NumGeometries(gc) AS nb_of_records,
        ST_AsText(ST_Centroid(gc)) AS center_coords
      FROM (
        SELECT unnest(ST_ClusterWithin(longlat, #{radius_in_degres})) gc
        FROM records
        #{"WHERE ST_Contains(ST_MakeEnvelope(#{@bounds.values.map(&:values).join(', ')}, 2154), longlat)" if @bounds.present?}
      ) f;
    EOF
  end

  def radius_in_degres
    @radius.to_f / 111.139
  end

  def render_as_hash
    @clusters_from_db.map do |cluster|
      center_coords = cluster['center_coords'].tr('POINT()', '').split
      center_long   = center_coords[0].to_f
      center_lat    = center_coords[1].to_f
      {
        id:     cluster['id'],
        name:   cluster['nb_of_records'],
        position: {
          lng: center_long,
          lat: center_lat
        }
      }
    end
  end
end
