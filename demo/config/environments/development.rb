Rails.application.configure do
	# Settings specified here will take precedence over those in config/application.rb.

	# In the development environment your application's code is reloaded on
	# every request. This slows down response time but is perfect for development
	# since you don't have to restart the web server when you make code changes.
	require 'erb'

	config_file = File.join(Rails.root,'config','smtp.yml')
	if File.exists?(config_file) == false
		raise "#{config_file} is missing!"
	end

	yaml = YAML.load(File.read(config_file))[Rails.env]

	config.action_mailer.delivery_method = :smtp
	config.action_mailer.smtp_settings = {
	    :address => "email.com",
	    :port => 465, # Port 25 is throttled on AWS
	    :user_name => ERB.new(yaml['username']).result, # Your SMTP user here.
	    :password => ERB.new(yaml['password']).result, # Your SMTP password here.
	    :authentication => :login,
	    :enable_starttls_auto => true
	}

	config.logger = ActiveSupport::Logger.new(
                     config.paths['log'].first, 1, 50 * 1024 * 1024)

	config.cache_classes = false

	# Do not eager load code on boot.
	config.eager_load = false

	# Show full error reports and disable caching.
	config.consider_all_requests_local       = true
	config.action_controller.perform_caching = false

	# Don't care if the mailer can't send.
	config.action_mailer.raise_delivery_errors = false
	config.action_mailer.default_url_options = { :host => 'localhost',:port => 3000 }


	# Print deprecation notices to the Rails logger.
	config.active_support.deprecation = :log

	# Raise an error on page load if there are pending migrations.
	config.active_record.migration_error = :page_load

	# Debug mode disables concatenation and preprocessing of assets.
	# This option may cause significant delays in view rendering with a large
	# number of complex assets.
	config.assets.debug = true

	# Asset digests allow you to set far-future HTTP expiration dates on all assets,
	# yet still be able to expire them through the digest params.
	config.assets.digest = true

	# Adds additional error checking when serving assets at runtime.
	# Checks for improperly declared sprockets dependencies.
	# Raises helpful error messages.
	config.assets.raise_runtime_errors = true

    config.web_console.whitelisted_ips = '192.168.0.0/16'

    # Raises error for missing translations
    # config.action_view.raise_on_missing_translations = true

	config.web_console.whitelisted_ips = '192.168.0.0/8', '172.0.0.0/8'
    Paperclip.options[:command_path] = "/usr/local/bin/"

	config.action_cable.url = "ws://localhost:3000/cable"
	config.action_cable.allowed_request_origins = ['http://localhost:3000', 'http://127.0.0.1:3000','chrome-extension://pfdhoblngboilpfeibdedpjgfnlcodoo','ws://localhost:3000']
end

# Used to generate links outside of views
Rails.application.routes.default_url_options = { :host => 'localhost', :protocol => 'http' }
