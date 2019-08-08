class ClusterSerializer < Blueprinter::Base
  identifier :id

  field :number_of_records

  field :record_ids

  field :position do |record, _option|
    coordinates = record.center_coords.coordinates

    { lat: coordinates[1], lng: coordinates[0] }
  end
end
