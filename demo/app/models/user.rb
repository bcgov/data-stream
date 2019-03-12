
class User < ApplicationRecord
	before_save :ensure_authentication_token
	attr_accessor :message
		
	def display_name
		email
	end

	# Include default devise modules. Others available are:
	# :registerable, :rememberable, :timeoutable and :omniauthable
	devise :database_authenticatable,
					:confirmable, 
					:recoverable,
					:trackable,
					:validatable,
					:lockable

	has_one :profile,:autosave =>true

	has_one :role
	
	def attributes
		super.merge('message' => self.message)

	end

	def self.current
		Thread.current[:current_user]
	end

	def self.current=(usr)
		Thread.current[:current_user] = usr
	end

	def as_json( options={} )
		json = super(options)
		json[:user_id] = json['id']
		json.delete('id')

		return json
	end

	def ensure_authentication_token()
		if self.authentication_token.nil? || self.authentication_token.blank?
			self.authentication_token = generate_authentication_token
		end
	end

	# Ensure we invalidate their current authentication session on password change
	def password=( new_password )
		self.authentication_token = generate_authentication_token
		super
	end

	def log_failed_login_attempt()
		self.failed_attempts += 1
		if failed_attempts > Devise.maximum_attempts
			errors.add(:email,I18n.t(:account_locked))
			if unlock_token.present? == false
				lock_access!
			end
		else
			save!
		end
	end

	def has_role?( role )
		return roles.find_by_name(role).nil? == false
	end


	private
		def generate_authentication_token()
			loop do
				token = Devise::friendly_token
				if User.where(authentication_token:token).first == nil
					return token
				end
			end
		end	
end
