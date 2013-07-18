class AddUrlIndexToReview < ActiveRecord::Migration
  def change
    add_index :reviews,  :url
  end
end
