require 'digest/sha1'
require 'active_record'

class User < ActiveRecord::Base

  # Relations
  has_many :utilizations
  has_many :applications, :through => :utilizations

  # Validators
  validates :login, :presence => true
  validates :login, :uniqueness => true

	validates :password, :presence => true


	#def password=(password)
		#unless password.empty?
	#		self[:password] = User.encrypt_password(password)
	#	end
	#end

	def self.encrypt_password(password)
    Digest::SHA1.hexdigest(password).inspect
	end

	def self.authentication(login, password)
		user = User.find_by_login(login)
		!user.nil? && user.password == User.encrypt_password(password)
	end

end
