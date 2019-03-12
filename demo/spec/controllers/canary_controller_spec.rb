require 'rails_helper'

describe CanaryController do

	describe "Test Endpoint" do
		it "Returns Things" do
			get :tweet
			expect(response).to have_http_status(:ok)
		end
	end

end