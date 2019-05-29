"SELECT *, ST_AsText(unnest(ST_ClusterWithin(longlat, 1))) FROM records"


query = <<~EOF
SELECT row_number() over () AS id,
  ST_NumGeometries(gc),
  gc AS geom_collection,
  ST_Centroid(gc) AS centroid,
  ST_MinimumBoundingCircle(gc) AS circle,
  sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius
FROM (
  SELECT unnest(ST_ClusterWithin(longlat, 2)) gc
  FROM records
) f;
EOF

# TEXTUAL
query = <<~EOF
SELECT row_number() over () AS id,
  ST_NumGeometries(gc),
  ST_AsText(gc) AS geom_collection,
  ST_AsText(ST_Centroid(gc)) AS centroid,
  ST_AsText(ST_MinimumBoundingCircle(gc)) AS circle,
  sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius
FROM (
  SELECT unnest(ST_ClusterWithin(longlat, 2)) gc
  FROM records
) f;
EOF

query = <<~EOF
SELECT row_number() over () AS id,
  ST_NumGeometries(gc),
  ST_AsText(ST_Centroid(gc)) AS centroid,
  sqrt(ST_Area(ST_MinimumBoundingCircle(gc)) / pi()) AS radius
FROM (
  SELECT unnest(ST_ClusterWithin(longlat, 2)) gc
  FROM records
) f;
EOF


"SELECT *, ST_ClusterDBSCAN(longlat, eps := 1, minpoints := 1) over () AS cluster_id FROM records"

eps = 0.1 ; mp = 1 ; records = Record.select("*, ST_ClusterDBSCAN(longlat, eps := #{eps}, minpoints := #{mp}) over () AS cluster_id")


"SELECT *,
ST_ClusterDBSCAN(longlat, eps := 1, minpoints := 1) over () AS cluster_id,
ST_AsText(ST_Centroid(longlat)) AS cluster_center_text,
ST_Centroid(longlat) AS cluster_center
FROM records"










