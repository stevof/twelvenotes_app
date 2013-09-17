require 'application_helper'
require 'notes_randomizer'

class TwelveNotesController < ApplicationController
	include ApplicationHelper
	include NotesRandomizer

	helper_method :escape_note_name
	
	def index

		@notes = get_notes

		respond_to do |format|
			format.html 
			format.js {}
		end
	end

	def get_notes
		type = (params[:type] == "flats" ? :flats : :sharps)
		get_12_notes(type)
	end

	def escape_note_name(note)
		# get rid of the "#" in the note name to make the note name string more easy to work with in ERB, HTML and JS code
		note.downcase.gsub('#', '_sh')
	end

	private :get_notes
end
