class ClustersController < ApplicationController
  def index
    render json: { clusters:  BuildClustersService.new(params).call }
  end
end
