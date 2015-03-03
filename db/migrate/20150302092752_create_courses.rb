class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, length: 40, null: false

      t.timestamps null: false
    end
  end
end
