

class ContentType < ActiveRecord::Base
	validates :name, presence: true
	def display_name
		name
	end
end
