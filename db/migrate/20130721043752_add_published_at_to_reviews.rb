class AddPublishedAtToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :published_at, :datetime
  end
end
