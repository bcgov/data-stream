class Api::V1::LightningsController < BaseApiController

	skip_before_action :authenticate_user_from_token!

	require 'net/http'
	require 'rest-client'
	require 'json'

	def receive_data

		id = request.headers["id"]
		x_api_key = request.headers["x-api-key"]
		
        unless id == Rails.application.secrets.id  && x_api_key == Rails.application.secrets.x_api_key
	        head :unauthorized
	    else
		    event = JSON.parse(request.body.read)

			if params[:data].present?  # this is the data received
				case
				when params[:filename].end_with?(".csv")
				   # do anything you want with the data received
				   # f.i. cache it -> Rails.cache.write('lightning_data_cache_key', params[:data])
		           # or for direct streaming -> ActionCable.server.broadcast("lightning_data_stream", {data: params[:data]})		    
				when params[:filename].end_with?(".shp")
				   # do anything you want with the data received
				   # f.i. cache it -> Rails.cache.write('fire_data_cache_key', params[:data])
				   # or for direct streaming -> ActionCable.server.broadcast("lightning_data_stream", {data: params[:data]})		    
				end

				render :json => {:status => 202}
			else
				render :json => {:status => 204}
			end
		end
	end

	def list_subscriptions

		id = request.headers["id"]
		x_api_key = request.headers["x-api-key"]

        unless id == Rails.application.secrets.id  && x_api_key == Rails.application.secrets.x_api_key
	        head :unauthorized
	    else
			url = ENV['BC_API_URL'] + "/v1/subscribe"
	        
            payload = Hash.new
	        payload['_id'] = nil
	        payload["datasetId"] = params['datasetId']
			payload["notificationUrl"] = ENV['RAILS_API_URL'] + "/api/v1/lightning"
			
			headers = Hash.new
            headers['Content-Type'] = 'application/json'
            headers['id'] = ENV['BC_API_ID']
            headers['x-api-key'] = ENV['BC_API_KEY'] 

	        response = RestClient.get(
		        url,
		        headers
			)
		    render :json => {:response => response, :status => response.code}
	    end	
	end

	def send_subscription

		id = request.headers["id"]
		x_api_key = request.headers["x-api-key"]

        unless id == Rails.application.secrets.id  && x_api_key == Rails.application.secrets.x_api_key
	        head :unauthorized
	    else
	        url = ENV['BC_API_URL'] + "/v1/subscribe"
	        
			payload = Hash.new
	        payload["datasetId"] = params['datasetId']
			payload["notificationUrl"] = ENV['RAILS_API_URL'] + "/api/v1/lightning"
			
	        headers = Hash.new
            headers['Content-Type'] = 'application/json'
            headers['id'] = ENV['BC_API_ID']
            headers['x-api-key'] = ENV['BC_API_KEY'] 

	        response = RestClient.post(
		        url,
		        payload.to_json,
			    headers
			)
		    render :json => {:response => response, :status => response.code}
	    end		
	end

	def trigger_notifications

		id = request.headers["id"]
		x_api_key = request.headers["x-api-key"]

        unless id == Rails.application.secrets.id  && x_api_key == Rails.application.secrets.x_api_key
	        head :unauthorized
	    else
			url = ENV['BC_API_URL'] + "/v1/notify"
	        
			payload = Hash.new
	        payload["datasetId"] = params['datasetId']

			headers = Hash.new
            headers['Content-Type'] = 'application/json'
            headers['id'] = ENV['BC_API_ID']
            headers['x-api-key'] = ENV['BC_API_KEY'] 

	        response = RestClient.post(
		        url,
		        payload.to_json,
				headers
			)
		    render :json => {:response => response, :status => response.code}
	    end
     end
end
