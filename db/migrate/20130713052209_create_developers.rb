class CreateDevelopers < ActiveRecord::Migration
  def change
    create_table :developers do |t|
      t.integer :code, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
