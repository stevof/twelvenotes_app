require 'uri'

def pause()
	# Sleeps/pauses Rspec execution. Useful when debugging a spec, e.g., in order to see what a page 
	# looks like or interact with the page before the test continues.
	# Will only pause if an environment variable 'PAUSE' is set, typically passed on the rspec command line.
	# This means that you can leave 'pause' commands in your spec code, and they will not be
	# executed when the specs are run for real (i.e., continuous integration tests, nightly builds, etc.)

  sleep_secs = ENV['PAUSE']
  if sleep_secs && sleep_secs != ''
    putsd
    putsd "Pausing #{sleep_secs}s..."
    putsd
    sleep sleep_secs.to_i
  end
end

def random_string(length)
	# returns a random string of specified length
  cs = [*'0'..'9', *'a'..'z', *'A'..'Z', ' ']
  length.times.map { cs.sample }.join.strip
end

def verify_html_element(element_name, nth_child_index, params = nil)
  #
  # Verifies an html element in a more thorough method than the typical Capybara one-line checks, such as:
  #   page.should have_selector('div.is_valid', text: 'something') 
  #   or page.find('div:nth-child(2)').text.should == 'hey now'
  # It tests not only that the basic selector exists, but verifies it's in the right nth-child index,
  # and can also check the id and css class (which are hard to do in a simple one-line Capybara call),
  # as well as giving you the option to verify more html attributes if desired.
  #
  # Also, it returns the html element object.
  #
  # params (a hash):
  #   You can pass any attribute that might be part of an html element: 
  #   class, id, type, width, etc.
  #   If an attribute name/value is passed, the function will check for it. 
  #   If it's passed and the value is nil, will verify the text is empty.
  #
  #   Special params:
  #     :text    - if you pass this, it will check the element's #text property (el.text.should == value)
  #     :visible - corresponds to the same option for Capybara's #find method: by default (if omitted) it's 
  #                true (only find visible elements). Pass false to find visible and invisible/hidden elements.

  locator = "#{element_name}:nth-child(#{nth_child_index})"
  putsd "verifying html: #{locator}"

  # visible = params.present? && params.has_key?(:visible) ? params[:visible] : true
  visible_param = params.present? && params.has_key?(:visible) ? { :visible => params[:visible] } : {}

  el = page.find(locator, visible_param)

  # validate the attributes
  if params.present?
    params.each do |key, value|
      case key
        when :text
          putsd "  el.text => '#{el.text}'"
          if value.nil?
            el.text.should be_empty
          else
            el.text.should == value
          end
        when :visible
          # ignore. we already handled this above in the #find method call
        else
          if value.nil?
            el[key.to_sym].should be_empty
          else
            el[key.to_sym].should == value
          end
      end
    end
  end

  el
end

def verify_href(absolute_href, expected_relative_href)
  # Verify the href for a Capybara <a> tag element. Capybara a_tag[:href] gives us the absolute path. 
  # Rails path methods give us a relative path. This method lets us easily test the expected path
  # by converting the absolute to a relative path.

  uri = URI(absolute_href)
  uri.path.should == expected_relative_href
end

def date_info(the_date)
  # helper function for debugging
  "#{the_date.strftime('%c %z') unless the_date.nil?} (#{the_date.class})"
end
