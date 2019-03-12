class Profile < ContentBase
  belongs_to :user
  def display_name
	  "%s - %s" % [friendly_name, user_id]
  end
end
