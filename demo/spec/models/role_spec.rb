
require 'rails_helper'

describe Role do
	[:client,:guest,:admin,:employee].each do |role|
		Role.find_or_create_by(:name => role)
	end

	it "has a name" do
		expect(Role.new().valid?).to be(false)
		expect(Role.new(name:"").valid?).to be(false)
		expect(Role.new(name:"name").valid?).to be(true)
	end

	describe "Seed data",:slow do
		before(:each) do
			load "#{Rails.root}/db/seeds.rb"
		end

		it "seeds an employee role" do
			expect(Role.find_by_name(:employee)).not_to be(nil)
		end

		it "seeds an admin role" do
			expect(Role.find_by_name(:admin)).not_to be(nil)
		end
	end
end
