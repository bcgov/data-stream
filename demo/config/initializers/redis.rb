uri = URI.parse(ENV["REDISTOGO"] || "redis:/redis:6379/15" )
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)