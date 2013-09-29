require 'spec_helper'
require 'notes_randomizer'
require 'constants'

describe "NotesRandomizer tests" do
	include TwelveNotes
	include NotesRandomizer
	include ApplicationHelper

	describe '- get random notes' do

		it '- should raise error with invalid type parameter' do
			expect{get_12_notes(:foobar)}.to raise_error(ArgumentError)
		end

		shared_examples_for '#get_12_notes' do
			# 
			# code that uses this shared example must define a variable via let:
			#   what_type => :default | :sharps | :flats
			#

			def are_any_notes_of_wrong_type(notes_array, the_type)
				# if the array is supposed to have sharps, it should not have any flats,
				# and vice versa

				the_symbol_we_dont_want = (the_type == :flats ? TwelveNotes::Constants::Notes::SHARP_SYMBOL 
																		: TwelveNotes::Constants::Notes::FLAT_SYMBOL)

				notes_array.any? { |n| n.include?(the_symbol_we_dont_want) }
			end

			@notes = nil

			before do

				# validate the parameter
				fail("Unrecognized value '#{what_type}' for 'what_type'") unless [:default, :sharps, :flats].include?(what_type)

				# call the method using the default (omitted) parameter if necessary
				if what_type == :default
					@notes = get_12_notes()
				else
					@notes = get_12_notes(what_type)
				end

				putsd "we got notes: #{@notes.inspect}"
			end

			it '- should be an array of 12 strings' do
				@notes.should_not be_nil
				@notes.should be_an(Array)
				@notes.length.should == 12
				@notes.each do |n|
					n.should be_a(String)
				end
			end

			it '- should contain valid notes' do
				
				# get the master list of notes that include either sharps or flats, based on the parameter
				# defined for this test
				master_list = TwelveNotes::Constants::Notes::ALL_NOTES[what_type == :default ? :sharps : what_type]

				# putsd "master list (#{what_type}): #{master_list.inspect}"

				@notes.each do |n|
					master_list.should include(n)
				end
			end

			it '- all 12 notes should be unique' do
				@notes.length.should == @notes.uniq.length
			end

			it '- should not contain the opposite type of notes' do
				# if the method was asked to get sharps, the result should not have flats,
				# and vice versa

				are_any_notes_of_wrong_type(@notes, what_type).should be_false
			end
		end

		describe '- get 12 randomized notes' do

			describe '- with sharps (default parameter)' do
				it_behaves_like '#get_12_notes' do
					let!(:what_type) {:default}
				end
			end

			describe '- with sharps (explicit parameter)' do
				it_behaves_like '#get_12_notes' do
					let!(:what_type) {:sharps}
				end
			end

			describe '- with flats' do
				it_behaves_like '#get_12_notes' do
					let!(:what_type) {:flats}
				end
			end	
		end

	end

	describe '- #get_random_values' do

		before do
			putsd
		end

		describe '- should raise error when number of values is less than 5' do
	
			(0..4).each do |count|

				it "- when count is #{count}" do
					expect{get_random_values(count)}.to raise_error(ArgumentError)
				end
			end
		end

		it '- should not raise error when number of values is 5' do
			expect{get_random_values(5)}.to_not raise_error(ArgumentError)
		end

		# since we're testing code that by its nature behaves randomly, let's run all the following tests
		# multiple times, getting various number of items. This increases the odds we'll catch errors
		# that only occur in certain scenarios, based on the randomness of the method.

		[5, 6, 7, 9, 10, 12, 17, 21, 27, 30, 34].each do |count|

			describe "- when count is #{count}" do

				@vals = nil

				before do
					@vals = get_random_values(count)
					putsd
					putsd "returned: #{@vals.inspect}"
				end

				it "- should return an array" do
					@vals.should be_an(Array)
				end

				it "- should not have any nils" do
					@vals.should_not include(nil)
				end

				it "- should only have numbers" do
					@vals.each do |n|
						n.should be_an(Integer)
					end
				end

				it " - length should be #{count}" do
					@vals.length.should == count
				end

				it "- should only have values between 1 and #{count}" do
					@vals.sort.should == (1..count).to_a
				end

				it "- adjacent numbers should not be consecutive" do
					for n in 1..@vals.length - 1
						# difference between adjacent values should be > 1
						diff = @vals[n] - @vals[n - 1]
						diff.abs.should be > 1
					end
				end

				it "- adjacent numbers should not be 1 and max" do
					for n in 1..@vals.length - 1
						
						# should not have 1 followed by max value
						if @vals[n - 1] == 1
							@vals[n].should_not == count
						end

						# should not have max value followed by 1
						if @vals[n - 1] == count
							@vals[n].should_not == 1
						end
					end					
				end
			end
		end
	end

	describe '- #array_values_are_consecutive_integers' do

		it '- should not be consecutive' do
			array_values_are_consecutive_integers([2, 4, 5, 6, 7], 7).should == false
		end

		it '- should be consecutive with 3 items in order' do
			array_values_are_consecutive_integers([2, 3, 4], 4).should == true
		end

		it '- should be consecutive with 3 items out of order' do
			array_values_are_consecutive_integers([4, 2, 3], 4).should == true
		end

		it '- should be consecutive with 12 items in order' do
			vals = (1..12).to_a
			array_values_are_consecutive_integers(vals, 12).should == true
		end

		it '- should be consecutive with 12 items out of order' do
			vals = (1..12).to_a.shuffle
			array_values_are_consecutive_integers(vals, 12).should == true
		end

		it '- empty array should return false' do
			array_values_are_consecutive_integers([], 1).should == false
		end

		it '- array with 1 integer should return false' do
			array_values_are_consecutive_integers([1], 1).should == false
		end

		it '- array with 1 nil should return false' do
			array_values_are_consecutive_integers([nil], 1).should == false
		end

		it '- array with integers and nils should return false' do
			array_values_are_consecutive_integers([23, 127, nil, 0, nil, 3], 256).should == false
		end

		it '- should be consecutive when it only contains 1 and max value' do
			array_values_are_consecutive_integers([1, 5], 5).should be_true			
		end

		it '- should be consecutive when values contain 1, 2 and max' do
			array_values_are_consecutive_integers([1, 2, 5], 5).should be_true
		end

		it '- should not be consecutive when it only contains 1 and less than max value' do
			array_values_are_consecutive_integers([1, 6], 7).should be_false
		end
	end
end