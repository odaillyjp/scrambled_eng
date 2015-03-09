class AddSequenceNumberToChallenges < ActiveRecord::Migration
  def change
    add_column :challenges, :sequence_number, :integer, null: false, default: 1
    add_index :challenges, :sequence_number
    add_index :challenges, [:course_id, :sequence_number], unique: true
  end
end
