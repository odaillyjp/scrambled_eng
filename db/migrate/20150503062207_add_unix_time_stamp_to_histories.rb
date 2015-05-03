class AddUnixTimeStampToHistories < ActiveRecord::Migration
  def up
    # PostgreSQLのintegerにlimitを指定するとエラーとなるので、とりあえずlimit指定は無しにする
    add_column :histories, :unix_timestamp, :integer, after: :challenge_id
    add_index :histories, [:unix_timestamp, :user_id]
    add_index :histories, [:unix_timestamp, :challenge_id]

    History.transaction do
      History.all.each do |history|
        history.update_attributes(unix_timestamp: history.created_at.beginning_of_day.to_i)
      end
    end

    change_column :histories, :unix_timestamp, :integer, null: false
  end

  def down
    remove_index :histories, [:unix_timestamp, :challenge_id]
    remove_index :histories, [:unix_timestamp, :user_id]
    remove_column :histories, :unix_timestamp
  end
end
