ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include Paperclip::Shoulda::Matchers
  include ValidAttribute::Method

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Paperclip::Shoulda::Matchers
  include Rails.application.routes.url_helpers
  include Warden::Test::Helper
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end