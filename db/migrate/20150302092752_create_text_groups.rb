class CreateTextGroups < ActiveRecord::Migration
  def change
    create_table :text_groups do |t|
      t.string :name, length: 40, null: false

      t.timestamps null: false
    end
  end
end
