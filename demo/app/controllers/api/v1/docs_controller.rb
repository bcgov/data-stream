class Api::V1::DocsController < ActionController::Base

	#prepend_before_action :disable_devise_trackable
	
	def api_doc
		render file: 'public/api_doc.html'
	end

	def openapi_yaml
		send_file(
		    "#{Rails.root}/public/assets/api.yaml",
		    filename: "api.yaml",
		    type: "application/yaml",
		    x_sendfile: true
		)
	end

end