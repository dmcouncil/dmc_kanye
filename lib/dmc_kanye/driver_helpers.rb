module DmcKanye

  class TimeoutException < RuntimeError; end

  module DriverHelpers

    # If the browser is waiting for ajax or loading a page, Kanye is smart
    # enough to deal with this.  However, if the browser is busy doing something
    # else for a significant period of time (such as long-running JavaScript),
    # Kanye is not smart enough to know that there is something that needs
    # finishing.
    #
    # So basically, in the very rare cases that Kanye cannot detect that something
    # needs to be waited for, you can explicitly wait for a DOM element to
    # appear, for example:
    #
    #   wait_to_appear(:css, '.ui-autocomplete.ui-menu')
    #
    # This will wait up to the poltergeist timeout value (which is probably
    # 30 seconds) for this DOM element to appear before moving on.  If the
    # DOM element does not appear, an error is thrown.
    #
    def wait_to_appear(method, selector)
      seconds = 0
      while find(method, selector).nil?
        seconds += 0.2
        raise TimeoutException if seconds > timeout
        sleep 0.2
      end
    end

    def open_ajax_requests?
      !evaluate_script("(typeof jQuery === 'undefined') ? 0 : jQuery.active").zero?
    rescue Capybara::NotSupportedByDriverError
      false
    end

    def page_loaded?
      evaluate_script("document.readyState") == "complete"
    rescue Capybara::NotSupportedByDriverError
      true
    end

    def wait_for_page_to_finish_loading
      seconds = 0
      while !page_loaded?
        seconds += 0.02
        raise TimeoutException if seconds > timeout
        sleep 0.02
      end
    end

    def wait_for_in_progress_ajax_to_finish
      seconds = 0
      while open_ajax_requests?
        seconds += 0.05
        raise TimeoutException if seconds > timeout
        sleep 0.05
      end
    end

    def wait_for_page_to_settle
      if !page_loaded?
        wait_for_page_to_finish_loading
        wait_for_page_to_settle
      end
      if open_ajax_requests?
        wait_for_in_progress_ajax_to_finish
        wait_for_page_to_settle
      end
    end
  end
end

module Capybara::Poltergeist
  class Driver < Capybara::Driver::Base
    include DmcKanye::DriverHelpers
  end
end
