class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.text       :en_text, null: false
      t.text       :ja_text, null: false
      t.references :course, index: true

      t.timestamps null: false
    end
    add_foreign_key :challenges, :courses
  end
end
