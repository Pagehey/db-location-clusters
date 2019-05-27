class RecordSerializer < Blueprinter::Base
  identifier :id

  field :name

  field :longitude

  field :latitude

  field :position do |record, _option|
    { lat: record.latitude, lng: record.longitude }
  end
end
