require 'active_record'

class Application < ActiveRecord::Base
	belongs_to :user

  has_many :utilizations
  has_many :users, :through => :utilizations

  validates :name, :presence => true
  validates :name, :uniqueness => true

  validates :url, :presence => true
  validates :url, :uniqueness => true

	validates :user_id, :presence => true
	validates :user_id, :numericality => true

	#DELETE METHOD
	def self.delete(appli)
		
		utilizations = Utilization.where(:application_id => appli.id)

		if utilizations != nil
			utilizations.each do |util|
    		util.destroy
    	end
		end
    appli.destroy

	end

	#REDIRECT METHOD
	def self.redirect(appli, origin, user)
		if !appli.nil?
			utilization = Utilization.new
			utilization.application_id = appli.id
			utilization.user_id = user.id
			utilization.save
			redirect = appli.url+origin+'?login='+user.login
		else
			redirect = '/'		
		end
		redirect
	end


end
