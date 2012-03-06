class Application < ActiveRecord::Base
  has_many :utilizations
  has_many :users, :through => :utilizations
end
