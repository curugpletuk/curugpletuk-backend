require 'sidekiq-scheduler'

class SessionWorker
	include Sidekiq::Worker

	def perform
		puts "Deleting Expired Session"
		Session.all.each do |session|
			if Time.now > (session.created_at + 360.minutes)
				session.delete
			end
		end
	end
end