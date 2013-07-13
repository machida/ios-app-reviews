class CreateAppReviews < ActiveRecord::Migration
  def change
    create_table :app_reviews do |t|
      t.references :app, index: true, null: false
      t.references :review, index: true, null: false

      t.timestamps
    end
  end
end
