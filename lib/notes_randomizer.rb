require 'constants'

module NotesRandomizer
	include TwelveNotes

	def get_12_notes(type = :sharps)
		# gets randomized set of 12 notes, where adjacent notes are more than 1/2 step apart
		# type => :sharps | :flats

		raise(ArgumentError, "Unrecognized value '#{type}' for 'type'") unless [:sharps, :flats].include?(type)

		notes_master_list = Constants::Notes::ALL_NOTES[type]
		note_vals = get_random_values(12)
		note_letters = []

		note_vals.each do |v|
			note_letters << notes_master_list[v - 1]
		end

		note_letters
	end

	def get_random_values(how_many)
		# gets array of numeric values (1..how_many) in random order, folllowing the logic that each adjacent
		# value must be more than 1 different from its neighbors (1 and max value are considered adjacent)

		# there are no possible combinations that meet our logical criteria when the number 
		# of items is less than 5
		raise(ArgumentError, "'how_many' must be at least 5") if how_many < 5

		selected_value = nil
		val_minus_1 = nil
		val_plus_1 = nil
		random_values = Array.new(how_many)

		note_values = (1..how_many).to_a

		(1..how_many).each do |n|

			putsd
			putsd "iteration #{n}: #{note_values.inspect}"

			# copy the current state of the base array
			temp_notes = Array.new(note_values)

			# we cannot select immediately adjacent notes
			# remove notes 1 step above and below the previously selected note from temp_notes
			if selected_value
				
				vals_to_delete = Array.new(2)

				# remove the value one less than than the selection
				vals_to_delete[0] =
					if selected_value == 1
						# ensure we don't select the max value next
						how_many
					else
						selected_value - 1
					end

				# remove the value one greater than the selection
				vals_to_delete[1] =
					if selected_value == how_many
						# ensure we don't select 1 next
						1
					else
						selected_value + 1
					end

				putsd "  excluding adjacent values from next selection: #{vals_to_delete.inspect}"

				vals_to_delete.each { |v| temp_notes.delete(v) }
			end

			putsd "temp_notes: #{temp_notes.inspect}"

			selected_value = nil
			break_out = false

			loop do

				# if we have already lopped one or more times, remove the value we previously rejected
				# to ensure it isn't sampled again (for efficiency). (First time through it won't delete anything 
				# because selected_value is nil)
				temp_notes_in_loop = Array.new(temp_notes)
				temp_notes_in_loop.delete(selected_value)

				putsd "temp_notes_in_loop: #{temp_notes_in_loop.inspect}"

				# select a random note from temp_notes
				selected_value = temp_notes_in_loop.sample

				putsd "tentative selected value = #{selected_value}"

				# the selection is only tentative -- we need to check something...

				case note_values.length
				when 3, 4, 5
					# before we whittle the remaining values down to a set of 4, 3 and then 2 values,
					# we must make sure we're not left with a set of consecutive values.
					# When the set size is 4, 3 and 2, if they are all consecutive there's no way to randomly 
					# order them without any two being consecutive (remember that we consider 1 and max value to be consecutive).

					putsd "only #{note_values.length - 1} items remaining. validating consecutivity..."

					possible_remaining_values = Array.new(note_values)
					possible_remaining_values.delete(selected_value)

					# we can keep the selected value IF the remaining values are not all consecutive
					break_out = !array_values_are_consecutive_integers(possible_remaining_values, how_many)

					putsd "rejected #{selected_value}. trying again..." unless break_out

				else
					break_out = true
				end

				break if break_out
			end

			putsd "Selected = #{selected_value}"

			# and save the random note in random_values
			random_values[n - 1] = selected_value

			# remove the selected note from the pool of notes
			note_values.delete(selected_value)
		end

		random_values
	end 

	def array_values_are_consecutive_integers(the_array, max_value)
		# the_array - array of integers
		# max_value - the maximum value we should ever expect to have in the array

		putsd the_array.inspect

		return false unless the_array.present?
		return false unless the_array.length > 1
		return false if the_array.include?(nil)

		# putsd 'array is valid, continuing...'

#		is_consec = true
		the_array.sort!

		# starting with the 2nd item minus the 1st, the values should equal 1
#		for i in 1..the_array.length - 1
#
#			# putsd "#{i}: the_array[i] (#{the_array[i]}) - the_array[i - 1] (#{the_array[i - 1]})"
#
#			if the_array[i] - the_array[i - 1] != 1
#				is_consec = false
#				# putsd 'non-consecutive found'
#				break
#			end
#		end

		is_consec = are_values_consecutive(the_array)

		# also, treat the first and last values as consecutive 

		# wraparound with consecutive values at the start

		if !is_consec && the_array[0] == 1 && the_array.last == max_value
			# if the array ends with the max value, treat it as zero and move it to the first index
			# so that if the values we're testing are for example [1,2,7] and max is 7, this must be considered three 
			# consecutive values because that's equivalent to [0,1,2] (max is shifted to zero)

			# [1,7]     => treat it like [0,1]
			# [1,2,7]   => treat it like [0,1,2]
			# [1,2,3,7] => treat it like [0,1,2,3]

			array_copy = Array.new(the_array)
			
			# remove the last item because it's the max value, and insert 0 as the first element
			array_copy.delete(the_array.last)
			array_copy.insert(0, 0)

			putsd "checking for wraparound at start: #{array_copy.inspect}"

			# now re-check the array for consecutivity
			is_consec = are_values_consecutive(array_copy)
		end

		# wraparound with consecutive values at the end
		
		if !is_consec && the_array.length >= 3 && the_array[0] == 1 && the_array.last == max_value

			# [1,6,7]   => treat it like [6,7,8]
			# [1,5,6,7] => treat it like [5,6,7,8]

			array_copy = Array.new(the_array)
			
			# remove the first item, and insert max_value+1 as the last element
			array_copy.delete(the_array.first)
			array_copy.insert(array_copy.length, max_value + 1)

			putsd "checking for wraparound at end: #{array_copy.inspect}"

			# now re-check the array for consecutivity
			is_consec = are_values_consecutive(array_copy)
		end

		is_consec
	end

private

	def are_values_consecutive(the_array)
		
		# assume values are all consecutive unless proven otherwise
		is_consec = true

		# starting with the 2nd item minus the 1st, the values should equal 1

		for i in 1..the_array.length - 1

			# putsd "#{i}: the_array[i] (#{the_array[i]}) - the_array[i - 1] (#{the_array[i - 1]})"

			if the_array[i] - the_array[i - 1] != 1
				is_consec = false
				# putsd 'non-consecutive found'
				break
			end
		end

		is_consec
	end
end
