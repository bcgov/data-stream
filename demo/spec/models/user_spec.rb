
require 'rails_helper'

describe User do
	describe "Authentication tokens" , :vcr do
		before(:each) do
			@user = User.new(:email => 'an@email.com',:password => 'apassword')
			@user.skip_confirmation!
		end

		it "creates an authentication token on save if one is not present" do
			@user.save!
			expect(@user.authentication_token).to_not be(nil)
		end

		it "does not change the authentication token on save if one is present" do
			@user.authentication_token = 'a_token'
			@user.save!
			expect(@user.authentication_token).to eq('a_token')
		end
	end

	describe "Login failure tracking" , :vcr do
		before(:each) do
			@user = User.new(:email => 'an@email.com',:password => 'apassword')
			@user.skip_confirmation!
			@user.save!
		end

		it "logs failed password attempts" do
			@user.log_failed_login_attempt()
			expect(@user.failed_attempts).to eq(1)
		end

		describe "Lock activation" do
			before(:each) do
				@user.failed_attempts = Devise.maximum_attempts
			end

			it "locks the account after a number of failed attempts",:slow do
				@user.log_failed_login_attempt()
				expect(@user.locked_at).to_not be(nil)
				expect(@user.unlock_token).to_not be(nil)
			end

			it "only generates an unlock token once",:slow do
				@user.log_failed_login_attempt()
				unlock_token = @user.unlock_token
				@user.log_failed_login_attempt()
				expect(@user.unlock_token).to eq(unlock_token)
			end
		end
	end

	describe "JSON serialization", :vcr do
		it "serializes" do
			user = User.new(:email => 'an@email.com',:password => 'apassword')
			user.skip_confirmation!
			user.save!
			expect(user.as_json(:only => [:id])).to eq({ :user_id => user.id })
		end
	end

	describe "Roles" do
		before(:each) do
			@u = User.new(:email => 'user',:password => 'password')
		end

		it "looks up it's role" do
			expect(@u.respond_to?(:has_role?)).to be(true)
		end
	end

	describe "User Create Retrieve Update Destroy" do
		before(:each) do
			@email = 'an@email.com'
			@password = 'a_password'
			user = User.new(email:@email,password:@password)
			user.skip_confirmation!
			user.save!
			@auth_token = user.authentication_token
			@id = user.id
		end

		it "disallows invalid email user create" do
			@bademail = 'look@mytest'
			user = User.new(email:@bademail,password:@password)
			expect(user.valid?).to eq(false)
		end

		it "disallows invalid password user create" do
			@badpassword = 'ABC'
			user = User.new(email:@email,password:@badpassword)
			expect(user.valid?).to eq(false)
		end

		it "allows valid user retrieve" do
			user = User.find_by_id(@id)
			expect(user.valid?).to eq(true)
		end

		it "disallows invalid user retrieve" do
			user = User.find_by(email: 'look@mytest')
			expect(user.blank?).to eq(true)
		end

		it "allows valid user updates" do
			user = User.find_by_id(@id)

			user.email = 'omg@newemail.com'
			expect(user.valid?).to eq(true)

			user.password = 'tH15N3wP@ssWord!!'
			expect(user.valid?).to eq(true)
		end

		it "disallows invalid user updates" do
			user = User.find_by_id(@id)

			user.update(email:@bademail)
			expect(user.valid?).to eq(false)

			user.update(password:@badpassword)
			expect(user.valid?).to eq(false)
		end
	end
end
