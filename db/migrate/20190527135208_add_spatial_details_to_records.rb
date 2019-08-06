class AddSpatialDetailsToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :lonlat, :st_point, srid: 2154
    add_index :records, :lonlat, using: :gist
  end
end
