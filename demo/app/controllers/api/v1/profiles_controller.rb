class Api::V1::ProfilesController < BaseApiController
	prepend_before_action :disable_devise_trackable
	def show
		render(:json => profile_as_json(current_user.profile),:status => :ok)
	end

  def update
    profile = current_user.profile
    profile.update(profile_params)

    render(:json => profile_as_json(profile),:status => :ok)
  end

  private
    def profile_params
      params.permit(:id, :friendly_name, :avatar, :tagline, :legacy_db, :legacy_db_timestamp, :level_of_detail, :user_id)
    end

	def profile_as_json( profile )
		return profile.as_json(:only => [:friendly_name, :tagline, :avatar, :legacy_db, :legacy_db_timestamp, :level_of_detail, :time_in_app, :time_in_store])
	end
    
	def disable_devise_trackable
		request.env["devise.skip_trackable"] = true
	end

end