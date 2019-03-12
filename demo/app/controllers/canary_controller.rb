class CanaryController < ApplicationController

	class TweetData
		include ActiveModel::Model
		attr_accessor :last_migration, :threads, :mb_free, :users, :precompiled, :healthy, :problems
	end

	def tweet
		# @todo set these as environment variables
		mb_free_threshold = 250
		db_thread_threshold = 40

		tweet_data = TweetData.new
		# Check Database Connection
		tweet_data.healthy = true
		problems = []
		if ActiveRecord::Base.connected?
			connection = ActiveRecord::Base.connection

			## Database Checks
			# Check Connection Pool
			tweet_data.threads = connection.execute("select count(*) from pg_stat_activity where pid <> pg_backend_pid();")[0]["count"].to_i
			if tweet_data.threads > db_thread_threshold
				tweet_data.healthy = false
				problems.push("Too many db threads open")
			end

			# Check Migration Status, this only succeeds if we have db migrated
			last_migration = connection.execute("select * from schema_migrations order by version DESC limit 1;")
			if last_migration.count == 1
				tweet_data.last_migration = last_migration[0]["version"]

				# Check number of users
				tweet_data.users = connection.execute("select count(*) from users;")[0]["count"].to_i
				if tweet_data.users == 0
					tweet_data.healthy  = false
					problems.push("No Users")
				end
			else
				 # we need to db migrate
				tweet_data.last_migration = ""
				tweet_data.healthy  = false
				problems.push("No DB Migrations")
			end

		else
			tweet_data.threads = nil
			tweet_data.last_migration = nil
			tweet_data.users = nil
			tweet_data.healthy  = false
			problems.push("No DB Connection")
		end

		# Check Disk Space
		bytes_free = `df -B1 .`.split[10].to_i
		tweet_data.mb_free = (bytes_free/1024)/1024

		if tweet_data.mb_free < mb_free_threshold
			tweet_data.healthy  = false
			problems.push("Low Disk Space")
		end

		# Check if pre compiled assets
		root_dir = File.join(File.dirname(__FILE__),"..","..")
		assets_last_modified_at  = Dir["#{root_dir}/app/assets/**/**"].map { |p| File.mtime(p) }.sort.last
		assets_last_compiled_at =  Dir["#{root_dir}/public/assets/**/**"].map { |p| File.mtime(p) }.sort.last

		if assets_last_compiled_at == nil || assets_last_modified_at > assets_last_compiled_at
			tweet_data.precompiled = false
			tweet_data.healthy  = false
			problems.push("No Asset Precompilation")
		else
			tweet_data.precompiled = true
		end

		tweet_data.problems = problems
		render(:json => tweet_data,:status => :ok)

	end

end
