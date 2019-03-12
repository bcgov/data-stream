require 'rails_helper'
require 'ostruct'

describe Accounts::ConfirmationsController do
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "renders the SHOW view when a user account is confirmed",:slow do
		u = User.create!(:email => 'test@test.com',:password => 'password')
		confirm_token = u.reload.confirmation_token

		get(:show, params: {:confirmation_token => confirm_token})
		expect(response).to render_template(:show)
	end

	it "renders the NEW view when a user is unable to be confirmed" do
		get(:show)
		expect(response).to render_template(:new)
	end
end
