class CreateAppCategories < ActiveRecord::Migration
  def change
    create_table :app_categories do |t|
      t.references :app, index: true, null: false
      t.references :category, index: true, null: false

      t.timestamps
    end
  end
end
