module Capybara::Poltergeist
  class Driver < Capybara::Driver::Base

    # allows Capybara to have different behaviors depending on whether
    # the current driver includes Kanye's algorithm
    def kanye_invited?
      true
    end

  private

    def imma_let_you_finish
      wait_for_in_progress_ajax_to_finish
      disable_transitions_if_new_page
    end

    def remove_transitions
      if DmcKanye::Config.script_to_disable_transitions.present?
        evaluate_script DmcKanye::Config.script_to_disable_transitions
      end
    rescue Capybara::NotSupportedByDriverError
      false
    end

    # if we are on a new page, run some JavaScript that attempts to disable
    # any JS/CSS transitions that would cause the browser process to get out of
    # sync with the Capbyara test process
    def disable_transitions_if_new_page
      @__current_url = current_url
      if @__current_url != @__previous_url
        wait_for_page_to_finish_loading
        remove_transitions
      end
      @__previous_url = @__current_url
    end

  end
end

##### VIOLENT DUCK PUNCHING AHEAD
#
# Here we have overridden the behavior of a method in Capybara.  The part
# that we added is highlighted below to make it easier when upgrading
# to a future version of Capybara.

##### THIS CODE IS ORIGINAL
module Capybara
  module Node
    class Base
##### START PUNCHING DUCKS
# orig code:
#       def synchronize(seconds=Capybara.default_max_wait_time, options = {})
# new code:
      def synchronize(seconds = nil, options = {})
        kanye_in_the_house = session.driver.respond_to?(:kanye_invited?) && session.driver.kanye_invited?
        if seconds
          seconds_to_wait = seconds
        elsif kanye_in_the_house
          seconds_to_wait = DmcKanye::Config.default_wait_time || Capybara.default_wait_time
        else
          seconds_to_wait = Capybara.default_max_wait_time
        end
##### STOP PUNCHING DUCKS, BACK TO ORIGINAL CODE
        start_time = Capybara::Helpers.monotonic_time

        if session.synchronized
          yield
        else
          session.synchronized = true
          begin
##### START PUNCHING DUCKS
# orig code:
#            yield
# new code:
            session.driver.send(:imma_let_you_finish) if kanye_in_the_house
            result = yield
            session.driver.send(:imma_let_you_finish) if kanye_in_the_house
            result
##### STOP PUNCHING DUCKS, BACK TO ORIGINAL CODE
          rescue => e
            session.raise_server_error!
            raise e unless driver.wait?
            raise e unless catch_error?(e, options[:errors])
##### START PUNCHING DUCKS
# orig code:
#            raise e if (Capybara::Helpers.monotonic_time - start_time) >= seconds
# new code:
            raise e if (Capybara::Helpers.monotonic_time - start_time) >= seconds_to_wait
##### STOP PUNCHING DUCKS, BACK TO ORIGINAL CODE
            sleep(0.05)
            raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Capybara::Helpers.monotonic_time == start_time
            reload if Capybara.automatic_reload
            retry
          ensure
            session.synchronized = false
          end
        end
      end
    end
  end
end
