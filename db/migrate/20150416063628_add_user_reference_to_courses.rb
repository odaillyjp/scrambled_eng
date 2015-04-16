class AddUserReferenceToCourses < ActiveRecord::Migration
  def up
    drop_table :courses

    create_table :courses do |t|
      t.string     :name, length: 40, null: false
      t.text       :description, length: 120
      t.integer    :level, limit: 1, default: 0, null: false
      t.references :user, index: true, null: false
      t.integer    :state, limit: 1, default: 0, null: false
      t.boolean    :updatable, default: false, null: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :courses

    create_table :courses do |t|
      t.string :name, length: 40, null: false

      t.timestamps null: false
    end
  end
end
