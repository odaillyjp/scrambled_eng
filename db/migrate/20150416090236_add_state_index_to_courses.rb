class AddStateIndexToCourses < ActiveRecord::Migration
  def change
    add_index :courses, :state
  end
end
