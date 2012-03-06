class Utilization < ActiveRecord::Base
  belongs_to :user			# foreign key - user_id
  belongs_to :application	# foreign key - application_id
end
