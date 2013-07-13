class AppReview < ActiveRecord::Base
  belongs_to :app
  belongs_to :review
end
