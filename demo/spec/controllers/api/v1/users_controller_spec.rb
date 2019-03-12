require 'rails_helper'


describe Api::V1::UsersController do
	before(:each) do
		@email = 'another@email.com'
		@password = 'a_password'

		user = User.new(:email => @email,:password => @password)
		user.skip_confirmation_notification!
		user.save!

		@auth_token = user.authentication_token
		@id = user.id
	end

	describe "Login" do
		it "temporarily allows an uncomfirmed user" do
			post :login, params: {email: @email, password: @password}
			expect(response).to have_http_status(:ok)
		end

		it "rejects an unknown user" do
			post :login, params: { :email => '_unknown_@user.com',:password => @password }
			expect(response).to have_http_status(:unauthorized)
		end

		it "rejects a known use with an incorrect password" do
			post :login, params: { :email => @email,:password => 'laksjflaksjf' }
			expect(response).to have_http_status(:unauthorized)
		end

		it "rejects a locked user" do
			user = User.find_by_id(@id)
			user.failed_attempts = Devise.maximum_attempts + 1			
			user.lock_access!(:send_instructions => false)

			post :login, params: { :email => @email, :password => @password }
			expect(response).to have_http_status(:found)
		end

		describe "Known user" do
			before(:each) do
				user = User.find_by_id(@id)
				user.skip_confirmation!
				user.save!				
			end

			it "logs in a confirmed user" do
				post :login, params: { :email => @email,:password => @password }
				expect(response).to have_http_status(:success)

				auth_token = User.find_by_id(@id).authentication_token
				body = JSON.parse(response.body)
				expect(body).to include("email" => @email,"user_id" => @id,"authentication_token" => auth_token)
			end

			it "changes authentication tokens on each login" do
				post :login, params: { :email => @email,:password => @password }
				expect(response).to have_http_status(:success)
				token1 = JSON.parse(response.body)["authentication_token"]

				post :login, params: { :email => @email,:password => @password }
				expect(response).to have_http_status(:success)
				token2 = JSON.parse(response.body)["authentication_token"]

				expect(token1).not_to eq(token2)
			end
       
	describe "User Profile Create Retrieve Update JSON Endpoints" do
		before(:each) do
			[:student,:professor,:admin,:employee].each do |role|
				Role.find_or_create_by(:name => role)
			end
		end

		it "allows creation via endpoint",:slow do
			@email = "testing@myapp.com"
			@password = "Password"

			post :create, params: { :user => { :email => @email,:password => @password,:profile => { :friendly_name => "Initial Name" } } }
			expect(response).to have_http_status(:success)
			body = JSON.parse(response.body)			
			expect(body).to include("email" => @email)
		end

		it "allows login via endpoint" do
			user = User.find_by_id(@id)
			user.skip_confirmation!
			user.confirm
			user.save!

			post :login, params: { :email => @email,:password => @password }
			expect(response).to have_http_status(:success)
			body = JSON.parse(response.body)
			expect(body).to include("email" => @email,"user_id" => @id)
		end
	end
end