class RecreateChallenges < ActiveRecord::Migration
  def up
    drop_table :challenges

    create_table :challenges do |t|
      t.text       :en_text, length: 1000, null: false
      t.text       :ja_text, length: 1000, null: false
      t.references :course, index: true, null: false
      t.integer    :sequence_number, null: false
      t.references :user, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :challenges, :courses
    add_index :challenges, [:course_id, :sequence_number], unique: true
  end

  def down
    drop_table :challenges

    create_table :challenges do |t|
      t.text       :en_text, null: false
      t.text       :ja_text, null: false
      t.references :course, index: true

      t.timestamps null: false
    end

    add_foreign_key :challenges, :courses
    add_column :challenges, :sequence_number, :integer, null: false, default: 1
    add_index :challenges, :sequence_number
    add_index :challenges, [:course_id, :sequence_number], unique: true
  end
end
