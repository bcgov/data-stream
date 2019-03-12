class ContentBase < ApplicationRecord
	self.abstract_class = true
	before_save :add_app_id

	# Default Scope does not affect Save in Rails 4.2.7
	def self.default_scope
		if User.current.present? && User.current[:current_app_id] != ""
			where(app_id:  User.current[:current_app_id])
		else
			where('1 = 1')
		end
	end

	def add_app_id
		if User.current.present? && User.current[:current_app_id] != ""
			self.app_id = User.current[:current_app_id]
		end
	end


end