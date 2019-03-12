Rails.application.routes.draw do

	# Serve websocket cable requests in-process
	#mount ActionCable.server => '/cable'

	devise_for :users, :skip => [:registrations], :controllers => {
		:unlocks => 'accounts/unlocks',
		:confirmations => 'accounts/confirmations',
		:passwords => 'accounts/passwords'
	}
	devise_scope :user do
		patch 'users/confirmation',:to => 'accounts/confirmations#update'
		put 'users/confirmation',:to => 'accounts/confirmations#update'
		patch 'users/unlock',:to => 'accounts/unlocks#update'
		put 'users/unlock',:to => 'accounts/unlocks#update'
	end

	namespace :api do
		namespace :v1 do
			post 'login',:to =>'users#login'
			resources :users,:only => [:create,:update,:destroy] do
				get 'profile',:to => 'profiles#show'
				get 'sync',:to => 'profiles#sync'
				patch 'set_analytics',:to => 'profiles#set_analytics'
				put 'set_analytics',:to => 'profiles#set_analytics'
				put 'profile',:to => 'profiles#update'
				patch 'profile',:to =>'profiles#update'
				put 'update_password',:to =>'users#update_password'
				patch 'update_password',:to => 'users#update_password'
			end
			post 'users/reset_password',:to => 'users#reset_password'

			post 'lightning', :to => 'lightnings#receive_data'
			get 'list_subscriptions', :to => 'lightnings#list_subscriptions'
			post 'subscribe', :to => 'lightnings#send_subscription' 
			post 'notify', :to => 'lightnings#trigger_notifications' 

			get 'api_doc', :to => 'docs#api_doc'
			get 'openapi_yaml', :to => 'docs#openapi_yaml'

			get 'written_contents/sync',:to => 'written_contents#sync'
			get 'written_contents/show',:to => 'written_contents#show'

		end
	end
    
	get 'canary/tweet' => 'canary#tweet'
	
	root :to => 'landing#landing'

	match '*unmatched', to: 'application#route_not_found', via: :all

	# The priority is based upon order of creation: first created -> highest priority.
	# See how all your routes lay out with "rake routes".

	# You can have the root of your site routed with "root"
	# root 'welcome#index'

	# Example of regular route:
	#   get 'products/:id' => 'catalog#view'

	# Example of named route that can be invoked with purchase_url(id: product.id)
	#   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

	# Example resource route (maps HTTP verbs to controller actions automatically):
	#   resources :products

	# Example resource route with options:
	#   resources :products do
	#     member do
	#       get 'short'
	#       post 'toggle'
	#     end
	#
	#     collection do
	#       get 'sold'
	#     end
	#   end

	# Example resource route with sub-resources:
	#   resources :products do
	#     resources :comments, :sales
	#     resource :seller
	#   end

	# Example resource route with more complex sub-resources:
	#   resources :products do
	#     resources :comments
	#     resources :sales do
	#       get 'recent', on: :collection
	#     end
	#   end

	# Example resource route with concerns:
	#   concern :toggleable do
	#     post 'toggle'
	#   end
	#   resources :posts, concerns: :toggleable
	#   resources :photos, concerns: :toggleable

	# Example resource route within a namespace:
	#   namespace :admin do
	#     # Directs /admin/products/* to Admin::ProductsController
	#     # (app/controllers/admin/products_controller.rb)
	#     resources :products
	#   end
end
