class RecordsController < ApplicationController
  def index
    render json: RecordSerializer.render(Record.all, root: :records)
  end

  def clusters
    clusters = BuildClustersService.new(params[:km]).call

    render json: clusters
  end
end
