class AddFormattedPriceToApps < ActiveRecord::Migration
  def change
    add_column :apps, :formatted_price, :string, null: false, default: ''
  end
end
