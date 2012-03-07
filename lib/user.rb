class User < ActiveRecord::Base
  has_many :utilizations
  has_many :applications, :through => :utilizations
  validates :login, :presence => true
  validates :login, :uniqueness => true
  validates :password, :presence => true
end
