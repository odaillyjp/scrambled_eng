class HistoriesController < ApplicationController
  def heatmap
    render json: History.heatmap_json(params[:user_id], params[:from], params[:to])
  end
end
