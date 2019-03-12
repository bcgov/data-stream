module TokenAuthentication
	extend ActiveSupport::Concern

	def authenticate_user_from_password!
		params.require(:email)
		params.require(:password)

		user = User.find_by_email(params[:email].downcase.strip)
		if user.present? == false
			raise(ActiveRecord::RecordNotFound,I18n.t(:user_not_found))
		end

		if user.valid_password?(params[:password]) == false
			user.log_failed_login_attempt()
			if user.errors.present?
				raise Errors::AccountLocked.new(user.errors.values.join(' * '))
			end

			raise(ActiveRecord::RecordNotFound,I18n.t(:bad_password))
		end

		if user.confirmed? == false && ((Time.now-Devise.allow_unconfirmed_access_for) > user.confirmation_sent_at)
			raise(Errors::AccountUnconfirmed.new(I18n.t(:account_unconfirmed)))
		end

		return user
	end

	def authenticate_user_from_token!
		#$currentapp = nil
		params.require(:user_id)
		params.require(:user_token)

		user = User.find_by_id(params[:user_id])
		if user.present? == false
			raise(Errors::UserNotFound.new(I18n.t(:user_not_found)))
		end
	#	$currentapp = user.current_app_id
		User.current = user
		#puts $currentapp.inspect
		if Devise.secure_compare(user.authentication_token,params[:user_token]) == false
			user.log_failed_login_attempt()
			raise(ActiveRecord::RecordNotFound,I18n.t(:unauthorized))
		end

		sign_in(user,:store => false)
		return user
	end
end
