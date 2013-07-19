class RemoveFormattedPriceFromApps < ActiveRecord::Migration
  def change
    remove_column :apps, :formatted_price
  end
end
