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

        # NOTE: user_id, course_id 両パラメータを条件にした検索はできない.
        #       両パラメータを条件にして検索するケースがなさそうなので, このようにしている.
        query = if params[:user_id]
                  heatmap_query_with_user_id(params[:user_id], from, to)
                elsif params[:course_id]
                  heatmap_query_with_course_id(params[:course_id], from, to)
                end

        ActiveRecord::Base.connection.select_all(query).rows.to_h.to_json
      end

      private

      def heatmap_query_with_user_id(user_id, from, to)
        query = case DB_ADAPTER
                when 'sqlite3' then heatmap_query_with_user_id_for_sqlite
                else fail 'unsupported adapter!'
                end

        ActiveRecord::Base.send(:sanitize_sql_array, [query, user_id, from, to])
      end

      def heatmap_query_with_course_id(course_id, from, to)
        query = case DB_ADAPTER
                when 'sqlite3' then heatmap_query_with_course_id_for_sqlite
                else fail 'unsupported adapter!'
                end

        ActiveRecord::Base.send(:sanitize_sql_array, [query, course_id, from, to])
      end

      def heatmap_query_with_user_id_for_sqlite
        <<-SQL
          SELECT
            STRFTIME('%s', updated_at) AS timestamp,
            COUNT(*) AS value
          FROM
            histories
          WHERE
            (user_id = ?) AND
            (updated_at BETWEEN ? AND ?)
          GROUP BY
            DATE(updated_at)
          ;
        SQL
      end

      def heatmap_query_with_course_id_for_sqlite
        <<-SQL
          SELECT
            STRFTIME('%s', updated_at) AS timestamp,
            COUNT(*) AS value
          FROM
            histories
          WHERE
            (challenge_id IN
              (SELECT
                challenge_id
              FROM
                challenges
              WHERE
                course_id = ?)
            ) AND
            (updated_at BETWEEN ? AND ?)
          GROUP BY
            DATE(updated_at)
          ;
        SQL
      end
    end
  end
end
