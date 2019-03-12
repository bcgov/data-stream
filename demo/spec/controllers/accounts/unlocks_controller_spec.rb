require 'rails_helper'
require 'ostruct'

#
# Devise's unlock system works a bit differently
# then its confirmation system.  The unlock system
# sends a "friendly" token to the user and then
# persists a SHA256 of that token in the database.
# As such, there is no way for the test to capture
# the friendly token to simply pass it as a query
# parameter to the GET request.
#
# So we monkey patch the controller so we can
# manipulate the code flow.
#
describe Accounts::UnlocksController do
	before(:each) do
		@request.env["devise.mapping"] = Devise.mappings[:user]
	end

	it "renders the SHOW view when a user account is unlocked" do
		class ResourceClass
			def unlock_access_by_token( token )
				OpenStruct.new(:errors => [])
			end
		end

		class Accounts::UnlocksController
			alias_method :orginal_resource_class,:resource_class

			def monkeyed?
				true
			end

			def resource_class
				ResourceClass.new
			end
		end

		get(:show)
		expect(response).to render_template(:show)
	end

	it "renders the NEW view when a user is unable to be unlocked" do
		if subject.monkeyed?
			class Accounts::UnlocksController
				alias_method :resource_class,:orginal_resource_class
			end
		end

		get(:show)
		expect(response).to render_template(:new)
	end
end
