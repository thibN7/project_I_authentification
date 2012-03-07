class Application < ActiveRecord::Base
  has_many :utilizations
  has_many :users, :through => :utilizations
  validates :name, :presence => true
  validates :name, :uniqueness => true
  validates :url, :presence => true
  validates :url, :uniqueness => true
end
