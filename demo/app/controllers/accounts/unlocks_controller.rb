module Accounts
	class UnlocksController < Devise::UnlocksController
		def show
			self.resource = resource_class.unlock_access_by_token(params[:unlock_token])
			if resource.errors.empty?
				render('devise/unlocks/show')
			else
				render('devise/unlocks/new')
			end
		end

		def update
			flash[:notice] = I18n.t(:already_done,:scope => :unlock)
			redirect_to(root_path)
		end		
	end
end
