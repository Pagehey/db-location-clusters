## DB CLUSTERING

### Installation pour une app existante

**PostreSQL extension PostGIS:**

GIS = _Geographic Information System_.

PostGis https://postgis.net/documentation/

**Gemfile**

activerecord-postgis-adapter https://github.com/rgeo/activerecord-postgis-adapter/

```ruby
gem 'activerecord-postgis-adapter'
```



**database.yml**

D'après la doc de l'adaptateur _postgis_:

> At minimum, you will need to change the `adapter` field from `postgresql` to `postgis`. Recommended configuration:

```yaml
development:
  username:           your_username
  adapter:            postgis
  host:               localhost
  schema_search_path: public
```

**Upgrading an Existing Database**

`rake db:gis:setup`

**Migrating existing table**

```ruby
class AddSpatialDetailsToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :lonlat, :st_point, srid: 2154
    add_index :records, :lonlat, using: :gist
  end
end

```

Le _SRID_ (Spatial reference system) est nécessaire pour que les queries fonctionnent correctement.

**Updating data**

 En admettant qu'il y a des colonnes `longitude` et `latitude`  sur la table

```ruby
Record.update_all("lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 2154)")
```

### Queries

Pour être executée, les queries ont juste besoin des bordures de la map. Le composant `VueGoogleMaps` permet de les récupérer via l'event `bounds_changed`.

Pour des raisons de lisibilité je les ai ensuite formatées comme suivant (fonction `setBounds()`):

```javascript
{
  nw: { lng: 23.307499000000007,  lat: 50.29837571781281 },
  se: { lng: -18.880000999999993, lat: 41.830995534859795 }
}
```

**1) Records query**

_app/controllers/records_controller.rb_

```ruby
bounds  = bounds.values.map(&:values).join(', ')

Record.where("ST_Contains(ST_MakeEnvelope(#{bounds}, 2154), lonlat)")
```

_built query_:

```sql
SELECT "records".* FROM "records" WHERE (ST_Contains(ST_MakeEnvelope(2.2877435526427234, 46.096297912562555, -2.9856939473572766, 44.353527880614664, 2154), lonlat))
```

Le duo de fonction `ST_Contains()` / `ST_MakeEnveloppe()` permet de ne sélectionner que les records visible sur la section de map affichée à partir de deux coins d'une map.

**2) Clusters query**

_exemple de query_:

```sql
SELECT
    row_number() over () AS id,
    ARRAY_AGG( id ) AS record_ids,
    COUNT( lonlat ) AS number_of_records,
    ST_AsText( ST_Centroid(ST_Collect( lonlat )) ) AS center_coords
  FROM records
  WHERE
    ST_Contains( ST_MakeEnvelope( 10.123905250000007, 48.89930319209617, -5.696407249999993,        43.41931312866122, 2154 ), lonlat )
  GROUP BY
      ST_SnapToGrid( ST_SetSRID( lonlat, 2154 ), 0.3 )
  ORDER BY
      number_of_records DESC
```

**SELECT**

- id : numéro de ligne utilisé comme id pour le cluster
- record_ids: tableau des ids des records présent dans le cluster
- number_of_records: nomber de records dans le cluster
- center_coords: coordonnées du centre du cluster, au format : `"POINT(48.89930319209617 -5.696407249999993)"` (grâce à la fonction `ST_AsText()`, sans ça, la colonne retourne un binaire)

**WHERE**

Même fonction que pour la records query.

**GROUP BY**

Tout se joue ici, c'est la fonction _ST_SnapToGrid_() qui permet de créer les cluster. La fonction `ST_SetSRID()` permet juste la manipulation des données en précisant le SRID. Le deuxième argument est le diamètre du cluster (_voir plus loin comment il est calculé_).

**PERFORMANCES**

Cette requête met entre _200ms_ et  _240ms_ à s'éxécuter avec 72000 records en DB et environ _750ms_ avec 212000.

### Services

Je te propose deux solution pour récupérer les clusters, dans deux services quasi identiques. Les deux renvoient la même data au format suivant:

```ruby
{
  clusters: [
    {
      id: 1,
      ids: [157827, 157828, 157829, ...],
      number_of_records: 21,
      position: {
        lng: -0.772857035911654,
        lat: 45.2247756994267
        }
      }
    ]
  }

```

`position` est construit de telle manière à respecter le format requis par le composant `VueGoogleMaps` pour afficher les markers.

Les services ont chacun besoin des bordures de la map récupérés dans les params pour fonctionner. Deux methodes aident à la construction de la query:

```ruby
def map_bounds
  @bounds.values.map(&:values).join(', ')
end
```

Celle-ci permet de construire la string de coordonnées nécessaire à la création de l'envelopper geographique pour le `WHERE`.

```ruby
def cluster_radius
  map_with_in_degrees = @bounds['nw']['lng'] - @bounds['se']['lng']

  map_with_in_degrees.fdiv(6).round(3)
end
```

Celle-ci permet de calculer le diamètre des clusters. La solution la plus efficace que j'ai trouvée est de se baser sur la largeur de la map affichées (ici en degrée, calculée grâce aux bordures) et de faire des clusters avec un diamètre d'un sixième de cette largeur. C'est ce qui produit les rendus les plus satisfaisants. Ce nombre peut être légèrement modifié à la hausse pour produire plus de clusters ou au contraire à la baisse pour moins de cluster, mais alors on perd en précision.

Ensuite, la différence entre les deux services se situent à la manière de faire la query. La premiere solution est dans `BuildClustersService` et utilise `ActiveRecord::Base.connection` pour executer une query créée à la main.

```ruby
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
```

L'inconvénient de cette méthode est qui faut ensuite parser la data récupérée:

```ruby
def clusters_as_hash
    @clusters_from_db.map do |cluster|
      center_coords = RGeo::Geos.factory.parse_wkt(cluster['center_coords']).coordinates
      record_ids    = cluster['record_ids'].tr('{},', ' ').split.map(&:to_i)

      {
        id:                cluster['id'],
        ids:               record_ids,
        number_of_records: cluster['number_of_records'],
        position:          { lng: center_coords[0], lat: center_coords[1] }
      }
    end
  end
```

Le `cluster['record_ids'].tr('{},', ' ').split.map(&:to_i)` n'est vraiment pas très élégant, je l'avoue, mais je n'ai pas réussi à trouver un moyen de récupérer les ids directement typecastés dans un tableau. Je les récupère sous ce format là: `"{157827, 157828, 157829, ...}"`.

`RGeo::Geos.factory.parse_wkt(cluster['center_coords'])` renvoie un objet `RGeo::Geos::CAPIPointImpl` qui répond à `coordinates` avec un tableau de coordonnées long et lat.

Le deuxième service `BuildClustersServiceBis`diffère dans le fait que les clusters sont récupéres à partir du model `Record` pour ensuite être sérializés par le `ClusterSerializer` (_app/serializers/cluster_serializer.rb_)

```ruby
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
```

L'inconvénient de cette méthod est l'incohérence entre le fait d'appeler `Record`alors qu'on veut des clusters. L'avantage cependant est qu'il n'y a pas besoin de formater la data.

### VueGoogleMap

Les clusters sont récupérés à chaque fois que la bordure de la map change, avec la fonction `debounce()` de lodash qui permet de pacer un peu les calls. C'est l'event `@bounds_changed`qui est utilisé pour ça. Je reformate à chaque fois les bordures fournies par l'event par un objet plus intelligible.

J'ai laissé quelques fonction et _computed_ pour afficher un peu d'informations comme la taille des clusters affichés, le nombre de clusters présents dans cette section de map et combien de records ça représente.

Et enfin, j'ai choisi comme stratégie d'affichage que si de tous les clusters présents, aucun ne réprésente plus que 3 records, on affiche directement les records plutôt que les clusters. C'est le compromis le plus intéressant que j'ai trouvé en terme de performances et lisibilité. Sachant qu'il semble arriver souvent qu'il y ait plusieurs records exactement sur la même coordonnées. Je te laisse voir si ça fais sens dans l'app finale.
