
class Role < ApplicationRecord
	validates :name,presence: true	

	has_many :users

	def display_name
		name
	end
end
