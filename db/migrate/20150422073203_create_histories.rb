class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :user, index: true, null: false
      t.references :challenge, index: true, null: false

      t.timestamps null: false
    end
  end
end
