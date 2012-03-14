require 'digest/sha1'
require 'active_record'

class User < ActiveRecord::Base

  # Relations
	has_many :applications
  has_many :utilizations
  has_many :applications, :through => :utilizations

  # Validators
  validates :login, :presence => true
  validates :login, :uniqueness => true

	validates :password, :presence => true


	def password=(password)
		  if !password.empty?
		  self[:password] = User.encrypt_password(password)
		  else
		  self[:password] = nil
		end
	end

	def self.encrypt_password(password)
    Digest::SHA1.hexdigest(password).inspect
	end

	def self.user_exists(login, password)
		user = User.find_by_login(login)
		!user.nil? && user.password == User.encrypt_password(password)
	end

end
