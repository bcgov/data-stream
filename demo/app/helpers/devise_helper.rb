module DeviseHelper
	def devise_has_lock_validation_errors?( resource )
		return check_for_errors(resource,'locked')
	end

	def devise_has_confirm_validation_errors?( resource )
		check_for_errors(resource,'confirm')
	end

	def devise_has_password_reset_validation_errors?( resource )
		check_for_errors(resource,'password')
	end
	
	private
		def check_for_errors( resource,token )
			error = false

			resource.errors.full_messages.each do |it|
				#puts it
				error = it.downcase.scan(token).size == 0
			end

			return error
		end
end
