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

  def is_active?(page_name, active_class_name = "current_page_item")
    # this should be called form a view. if we're on the current page, return a css class name
    # (that we can use to highlight the active page in a nav menu, for example)

    puts
    puts "#is_active?"
    puts "params[:action] == #{params[:action]}"
    puts "page_name == #{page_name}"
    puts "current_page?(page_name) == #{current_page?(page_name)}"
    puts "params:"
    puts params.inspect
    puts

    active_class_name if [params[:controller], params[:action]].include?(page_name)
  end  
end
