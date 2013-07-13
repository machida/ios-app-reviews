class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.references :reviewer, index: true
      t.string :title, null: false
      t.string :url, null: false

      t.timestamps
    end
  end
end
