class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery :with => :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

	include Current
	include Devise

	def route_not_found
		render :json=>'', status: :not_found, layout: false
	end

end
