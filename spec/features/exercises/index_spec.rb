require 'spec_helper'

describe 'Exercises index page' do
	include ApplicationHelper
	
	before do
		visit exercises_path
		pause
	end

	it '- should be on the Exercises index page' do
		page.should have_content('Exercises')
		page.should have_content('VARIOUS PRACTICE EXERCISES YOU CAN TRY')
	end
	
end