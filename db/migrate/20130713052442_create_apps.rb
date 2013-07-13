class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.integer :code, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.integer :price, null: false
      t.integer :formatted_price, null: false
      t.decimal :rating, null: false
      t.string :version, null: false
      t.text :description, null: false
      t.string :artwork60_url, null: false
      t.string :artwork100_url, null: false
      t.string :artwork512_url, null: false
      t.references :developer, index: true, null: false
      t.references :primary_category, index: true, null: false

      t.timestamps
    end
  end
end
