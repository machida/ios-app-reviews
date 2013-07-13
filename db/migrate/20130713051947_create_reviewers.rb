class CreateReviewers < ActiveRecord::Migration
  def change
    create_table :reviewers do |t|
      t.integer :code, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.string :feed_url, null: false

      t.timestamps
    end
  end
end
