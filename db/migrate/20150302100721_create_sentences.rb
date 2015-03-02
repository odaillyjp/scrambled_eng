class CreateSentences < ActiveRecord::Migration
  def change
    create_table :sentences do |t|
      t.text       :en_text, null: false
      t.text       :ja_text, null: false
      t.references :text_group, index: true

      t.timestamps null: false
    end
    add_foreign_key :sentences, :text_groups
  end
end
