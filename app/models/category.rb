class Category < ActiveRecord::Base
  has_many :app_categories, dependent: :destroy
  has_many :apps, through: :app_categories
end
