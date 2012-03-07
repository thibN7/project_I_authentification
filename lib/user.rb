require 'password'

class User < ActiveRecord::Base

  include Password

  # Relations
  has_many :utilizations
  has_many :applications, :through => :utilizations

  # Validators
  validates :login, :presence => true
  validates :login, :uniqueness => true
  validates :password, :presence => true
end
