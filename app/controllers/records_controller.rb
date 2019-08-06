class RecordsController < ApplicationController
  def index
    raise 'NO BOUNDS!' unless params[:bounds].present?

    bounds  = JSON.parse(params[:bounds])
    bounds  = bounds.values.map(&:values).join(', ')
    records = Record.where("ST_Contains(ST_MakeEnvelope(#{bounds}, 2154), lonlat)")

    render json: RecordSerializer.render(records, root: :records)
  end
end
