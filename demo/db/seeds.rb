# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Roles
[:client,:guest,:admin,:employee].each do |role|
	Role.find_or_create_by(:name => role)
end

# Users
email = ENV['ADMIN_EMAIL']
password = ENV['ADMIN_PASSWORD']

if email.nil?
	email = 'admin@myapi.com'
end

if password.nil?
	password = 'aseriouspassword'
end


if email.present? && password.present?
	admin = User.find_or_initialize_by(:email => email)
	admin.password = password
    admin.current_app_id = 'MyApp'
	admin.profile = Profile.new
	admin.confirm
	role_id = Role.find_by_name(:admin).id
	user_id = admin.id
	puts "Role ID: #{role_id.to_s} User ID: #{user_id.to_s}"
	admin.save!
end