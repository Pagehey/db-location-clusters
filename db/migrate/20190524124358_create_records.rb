class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.float :longitude
      t.float :latitude
      t.string :reference

      t.timestamps
    end
  end
end
