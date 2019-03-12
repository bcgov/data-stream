class AuthorizationAbility
	include CanCan::Ability

	def initialize( user )
		#
		# It is possible to ask for authorization when
		# not yet signed in.  In this case just create
		# a plain jane new user just don't persist it.
		#
		user ||= User.new

		#
		# See the wiki for details:
		# https://github.com/ryanb/cancan/wiki/Defining-Abilities
		#
		if user.has_role?(:admin)
			can(:manage,:all)
		else
			can(:manage,nil)
		end
	end
end
