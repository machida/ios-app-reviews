class Review < ActiveRecord::Base
  belongs_to :reviewer
  has_many :app_reviews, dependent: :destroy
  has_many :apps, through: :app_reviews
end
