module ApplicationHelper

	# puts only when in debug mode
	def putsd(value = "")
	  if ENV['DEBUG'] == 'true'
	    puts value
	  end
	end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Twelve Notes"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
