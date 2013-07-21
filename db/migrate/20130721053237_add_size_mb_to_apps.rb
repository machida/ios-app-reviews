class AddSizeMbToApps < ActiveRecord::Migration
  def change
    add_column :apps, :size_mb, :decimal, null: false, default: 0.0
  end
end
