class BuildClustersService
  def initialize(params)
    @radius        = params[:radius]
    @bounds        = JSON.parse params[:bounds] if params[:bounds].present?
    @ar_connection = ActiveRecord::Base.connection
  end

  def call
    @clusters_from_db = @ar_connection.execute query
    render_as_hash
  end

  private

  def query
    <<~EOF
      SELECT
        row_number() over () AS id,
        array_agg(id) AS ids,
        COUNT( lonlat ) AS nb_of_records,
        ST_AsText( ST_Centroid(ST_Collect( lonlat )) ) AS center_coords
      FROM records
      #{"WHERE ST_Contains(ST_MakeEnvelope(#{@bounds.values.map(&:values).join(', ')}, 2154), lonlat)" if @bounds.present?}
      GROUP BY
          ST_SnapToGrid( ST_SetSRID(lonlat, 2154), #{radius_in_degres})
      ORDER BY
          nb_of_records DESC
      ;
    EOF
  end

  def radius_in_degres # permets de convertir une valeur en kilomètres en degré d'angle pour la query PostGIS (1def =~ 111,139km )
    (@bounds['nw']['lng'] - @bounds['se']['lng']).fdiv(6).round(3)
  end

  def render_as_hash
    @clusters_from_db.map do |cluster|
      center_coords = cluster['center_coords'].tr('POINT()', '').split
      {
        id:     cluster['id'],
        ids: cluster['ids'],
        reference:   cluster['nb_of_records'],
        position: {
          lng: center_coords[0].to_f,
          lat: center_coords[1].to_f
        }
      }
    end
  end
end
