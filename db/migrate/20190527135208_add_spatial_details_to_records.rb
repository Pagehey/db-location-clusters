class AddSpatialDetailsToRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :records, :longlat, :st_point, srid: 2154
    add_index :records, :longlat, using: :gist
  end
end
