class ClustersController < ApplicationController
  def index
    bounds = JSON.parse(params[:bounds])

    render json: { clusters: BuildClustersService.new(bounds).call }
    # render json: { clusters: BuildClustersServiceBis.new(bounds).call }
  end
end
