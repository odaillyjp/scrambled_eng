class AllowNullToUserIdOfHistories < ActiveRecord::Migration
  def up
    change_column :histories, :user_id, :integer, null: true
  end

  def down
    change_column :histories, :user_id, :integer, null: false
  end
end
