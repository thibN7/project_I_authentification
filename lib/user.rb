class User < ActiveRecord::Base
  has_many :utilizations
  has_many :applications, :through => :utilizations
end
