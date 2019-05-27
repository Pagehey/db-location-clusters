class RecordsController < ApplicationController
  def index
    render json: RecordSerializer.render(Record.all, root: :records)
  end
end
