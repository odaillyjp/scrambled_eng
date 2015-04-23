class HistoriesController < ApplicationController
  def heatmap
    json_data = HistoryHeatmap::Generator.run(params.extract!(:course_id, :user_id, :from, :to))
    render json: json_data
  end
end
