module Accounts
	class ConfirmationsController < Devise::ConfirmationsController
		def show
			self.resource = resource_class.confirm_by_token(params[:confirmation_token])
			if resource.errors.empty?
				render('devise/confirmations/show')
			else
				render('devise/confirmations/new')
			end
		end

		def update
			flash[:notice] = I18n.t(:already_done,:scope => :confirm)
			redirect_to(root_path)
		end
	end
end
