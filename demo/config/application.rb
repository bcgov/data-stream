require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Platform
	class Application < Rails::Application
		# Settings in config/environments/* take precedence over those specified here.
		# Application configuration should go into files in config/initializers
		# -- all .rb files in that directory are automatically loaded.

		# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
		# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
		config.time_zone = 'Pacific Time (US & Canada)'

		# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
		# config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
		# config.i18n.default_locale = :de

		# Do not swallow errors in after_commit/after_rollback callbacks.
		#config.active_record.raise_in_transactional_callbacks = true

		config.api_only = false

		config.frig_off_active_admin = true
		#config.eager_load_paths += %W(#{config.root}/lib)
		config.paths.add "lib", eager_load: true
		config.paths.add "jobs", eager_load: true

		# Action Cable can run alongside a Rails application.
		# For example, to listen for WebSocket requests on /websocket do this
		#config.action_cable.mount_path = '/websocket'

		#ActiveJob::Base.queue_adapter = :sidekiq
	end
end
