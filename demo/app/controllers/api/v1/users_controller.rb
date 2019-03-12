class Api::V1::UsersController < BaseApiController
	skip_before_action :authenticate_user_from_token!, :only => [:login,:create,:reset_password]

	# Sample body:
	# {
	# 	"email":"user@domain.com",
	# 	"password":"a password",
	#   "device_uuid":""
	# }
	#

	require 'action_view'

	include ActionView::Helpers::DateHelper


	def login
		user = authenticate_user_from_password!

		if user.present?
			handle_single_user_session(user)
			sign_in(user,:force => true)
			message = 'Successfully logged in!'
			user.save
			render(:json => user.as_json(:only => [:id,:email,:authentication_token, :message]))

		else
		   render(:json => { msg:I18n.t(:unauthorized) },:status => :unauthorized)
		end
	end

	def create
		user = User.new(user_params)
		user.profile = Profile.new(profile_params)
		if user.save!
			raw,enc = Devise.token_generator.generate(User,:confirmation_token)
			user.confirmation_token = enc
			user.confirmation_sent_at = Time.now.utc
			user.save(:validate => false)
			render(:json => user.as_json(:only => [:id,:email]))
		else
			render(:json => {msg:I18n.t(:account_email_exists)}, :status => :unprocessable_entity)
		end
	end

	def update
		user = current_user
		if user.update(user_update_params)
			render(:json => user.as_json(:only => [:id,:email]))
		else
			render(:json => user.errors, :status => :unprocessable_entity)
		end
	end

	def profile
		profile = current_user.profile
		render(:json => profile,:status => :ok)
	end

	def update_password
		#check current password against encrypted password
		if !(Devise::Encryptor.compare(User,current_user.encrypted_password,user_update_params[:current_password]))
			render(:json => { :message => "password mismatch" }, :status => :unprocessable_entity)
			return
		end

		current_user.password = user_update_params[:password]
		if current_user.save!
			UserMailer.password_change(current_user).deliver
			render(:json => {},:status => :ok)
		else
			if user.present?
				render(:json => user.errors, :status => :unprocessable_entity)
			else
				render(:json => { :message => "User Not Found!" }, :status => :unprocessable_entity)
			end


		end
	end

	def reset_password
		user = User.find_by(email: reset_params[:email])
		if user.present?
			raw, enc = Devise.token_generator.generate(User, :reset_password_token)
			user.reset_password_token = enc
			user.reset_password_sent_at = Time.now.utc
			if user.save!
				UserMailer.reset_password_instructions(user, raw).deliver
				render(:json => {},:status => :ok)
			else
				if user.present?
					render(:json => user.errors, :status => :unprocessable_entity)
				else
					render(:json => { :message => "Email Not Found!" }, :status => :unprocessable_entity)
				end
			end
		else
			render(:json => {}, :status => :user_not_found)
		end

	end

	private

		def user_params
			p = params[:user]
			{ :email => p[:email], :password => p[:password] }
		end

		def profile_params
			p = params[:user]
			{ :friendly_name => p[:friendly_name]}
		end

		def user_update_params
			p = params
			{ :password => p[:password], :password_confirmation => p[:password_confirmation], :current_password => p[:current_password] }
		end

		def reset_params
			p = params
			{:email => p[:email].downcase }
		end

		def handle_single_user_session( user )
			#
			# The business wants a single session per user.  So, each
			# login generates a new authentication_token which renders
			# any previous signs useless.
			#
			# By setting the user's authentication_token to nil a new
			# one will be generated when the model is saved.  The act
			# of signing in saves the user model. 
			#
			user.authentication_token = nil			
		end
	end