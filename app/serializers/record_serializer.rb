class RecordSerializer < Blueprinter::Base
  identifier :id

  field :reference

  field :longitude

  field :latitude

  field :position do |record, _option|
    { lat: record.latitude, lng: record.longitude }
  end
end
