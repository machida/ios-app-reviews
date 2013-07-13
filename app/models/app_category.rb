class AppCategory < ActiveRecord::Base
  belongs_to :app
  belongs_to :category
end
