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

	def self.delete(appli_id, user)
		app = Application.find_by_id(appli_id)
		user = User.find_by_login(user)
		
		if !app.nil? && !user.nil?
			if user.id == app.user_id
				utilizations = Utilization.where(:application_id => app.id)
				utilizations.each do |util|
					util.destroy
				end
				app.destroy
			else
				@error_not_owner = true
			end
		else
			@error_app = true
		end			

	end

end
