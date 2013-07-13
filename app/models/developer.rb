class Developer < ActiveRecord::Base
  has_many :apps, dependent: :destroy
end
