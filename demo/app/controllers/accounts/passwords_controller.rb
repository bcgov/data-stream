module Accounts
	class PasswordsController < Devise::PasswordsController
		def create
			self.resource = resource_class.send_reset_password_instructions(resource_params)
			yield resource if block_given?

			if successfully_sent?(resource)
				flash[:notice] = I18n.t(:notification,:scope => :password)
				redirect_to(root_path)
			else
				respond_with(resource)
			end
		end

		def update
			self.resource = resource_class.reset_password_by_token(resource_params)
			yield resource if block_given?
			if resource.errors.empty?
				resource.unlock_access! if unlockable?(resource)
				set_flash_message!(:notice,:updated_not_active)
				render('devise/passwords/success')
			else
				set_minimum_password_length
				respond_with resource
			end
		end

		protected
			def translation_scope
				'devise.passwords'
			end

			def unlockable?(resource)
				resource.respond_to?(:unlock_access!) &&
				resource.respond_to?(:unlock_strategy_enabled?) &&
				resource.unlock_strategy_enabled?(:email)
			end

			def after_sending_reset_password_instructions_path_for( resource_name )
				root_path
			end
	end
end
