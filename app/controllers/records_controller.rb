class RecordsController < ApplicationController
  def index
    bounds  = JSON.parse(params[:bounds])
    if bounds.present?
      bounds  = bounds.values.map(&:values).join(', ')
      records = Record.where("ST_Contains(ST_MakeEnvelope(#{bounds}, 2154), longlat)")
    else
      records = Record.all
    end

    render json: {
      records:   RecordSerializer.render_as_hash(records),
      clusters:  BuildClustersService.new(params).call
    }
  end
end
