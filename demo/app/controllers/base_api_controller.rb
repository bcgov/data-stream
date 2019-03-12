class BaseApiController < ActionController::API
	include TokenAuthentication
	include Current
	include Devise


	respond_to :json

	before_action :authenticate_user_from_token!
	before_action :set_current_app

	def set_current_app
    if current_user.present?
			Current.current_app = current_user.current_app_id
		else
			Current.current_app = ""
    end
	end

	rescue_from ActionController::ParameterMissing do |exception|
		validation_error(exception.message)
	end

	rescue_from ActionController::RoutingError do |exception|
		no_route(exception.message)
	end

	rescue_from ActionController::UnpermittedParameters do |exception|
		validation_error(exception.message)
	end

	rescue_from ActiveRecord::RecordInvalid do |exception|
		validation_error(exception.message)
	end

	rescue_from ActiveRecord::RecordNotFound do |exception|
		unauthorized(exception.message)
	end

	rescue_from ActionDispatch::Http::Parameters::ParseError do |exception|
		validation_error(exception.message)
	end

	rescue_from Errors::AccountLocked do |exception|
		forbidden(exception.message)
	end

	rescue_from Errors::AccountUnconfirmed do |exception|
		forbidden(exception.message)
	end
	
	rescue_from Errors::UserNotFound do |exception|
		not_found(exception.message)
	end

	def validation_error( message )
		render(:json => { msg: message },:status => :bad_request)
	end

	def unauthorized( message )
		render(:json =>{ msg: message },:status => :unauthorized)
	end

	def internal_error
		render json: { msg: I18n.t(:internal_server_error) }, status: :internal_server_error
	end

	def no_route
		render json: { msg: I18n.t(:route_not_found) }, status: :not_found
	end

	def forbidden( message )
		render json: { msg: message }, status: :forbidden
	end

	def not_found( message )
		render json: { msg: message }, status: :not_found
	end

	def unprocessable_entity( message )
		render json: { msg: message }, status: :unprocessable_entity
	end

end
