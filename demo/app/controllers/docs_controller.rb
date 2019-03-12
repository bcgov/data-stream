class DocsController < ActionController::Base

	prepend_before_action :disable_devise_trackable
	
	def api_doc
		render file: 'public/api_doc.html'
	end

	def openapi_yaml
		render file: 'public/assets/api.yaml'
	end

end