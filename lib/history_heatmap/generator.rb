module HistoryHeatmap
  module Generator
    # NOTE: HeatmapJSONを作成する部分はパフォーマンスを優先したかったので SQL を使用した.
    #       コードの書き方によるが、AR+Ruby で処理より SQL の方が速度が2倍以上早かった.

    class << self
      DB_ADAPTER = ActiveRecord::Base.configurations[Rails.env]['adapter']

      # CalHeatmap.jsのデータとして扱うことができるJSONを返す
      #
      # ex.
      #   HistoryHeatmap::Generator.run(user_id: 1, from: '2015-01-01', to: '2015-12-31')
      #   # => "{'19401031': 4, '19403142': 2}"
      #
      def run(params)
        from = params[:from] || Time.current
        to = params[:to] || Time.current

        histories = History.where(updated_at: from..to)
        histories = histories.where(user_id: params[:user_id]) if params[:user_id]
        if params[:course_id]
          histories = histories.joins(:challenge)
                        .where(challenges: { course_id: params[:course_id] })
        end
        histories.group(:unix_timestamp).count
      end
    end
  end
end
