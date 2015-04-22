# == Schema Information
#
# Table name: histories
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  challenge_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class History < ActiveRecord::Base
  belongs_to :user
  belongs_to :challenge

  validates :user_id, presence: true
  validates :challenge_id, presence: true

  def self.heatmap_json(user_id, from, to)
    # NOTE: 開発環境と本番環境でDBアダプタが異なるので生SQLを使いたくなかったが、
    # パフォーマンスを優先したい部分だったのでやむなく生SQLを使った。
    query = case ActiveRecord::Base.configurations[Rails.env]['adapter']
            when 'sqlite3' then heatmap_query_for_sqlite
            else fail 'unsupported adapter!'
            end

    query = ActiveRecord::Base.send(:sanitize_sql_array, [query, user_id, from, to])
    ActiveRecord::Base.connection.select_all(query).rows.to_h.to_json
  end

  private

  def self.heatmap_query_for_sqlite
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
end
