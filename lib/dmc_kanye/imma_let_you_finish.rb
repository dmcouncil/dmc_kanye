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
#
# Original code lives here: https://github.com/teamcapybara/capybara/blob/3.40.0/lib/capybara/node/base.rb#L76

##### THIS CODE IS ORIGINAL
module Capybara
  module Node
    class Base
      def synchronize(seconds = nil, errors: nil)
        return yield if session.synchronized
##### START PUNCHING DUCKS
# orig code:
#       seconds = session_options.default_max_wait_time if [nil, true].include? seconds
# new code:
        kanye_in_the_house = session.driver.respond_to?(:kanye_invited?) && session.driver.kanye_invited?
        if [nil, true].include? seconds
          if kanye_in_the_house
            seconds = DmcKanye::Config.default_wait_time || session_options.default_max_wait_time
          else
            seconds = session_options.default_max_wait_time
          end
        end
##### STOP PUNCHING DUCKS, BACK TO ORIGINAL CODE
        interval = session_options.default_retry_interval
        session.synchronized = true
        timer = Capybara::Helpers.timer(expire_in: seconds)
        begin
##### START PUNCHING DUCKS
# orig code:
#         yield
# new code:
          session.driver.send(:imma_let_you_finish) if kanye_in_the_house
          result = yield
          session.driver.send(:imma_let_you_finish) if kanye_in_the_house
          result
##### STOP PUNCHING DUCKS, BACK TO ORIGINAL CODE
        rescue StandardError => e
          session.raise_server_error!
          raise e unless catch_error?(e, errors)

          if driver.wait?
            raise e if timer.expired?

            sleep interval
            reload if session_options.automatic_reload
          else
            old_base = @base
            reload if session_options.automatic_reload
            raise e if old_base == @base
          end
          retry
        ensure
          session.synchronized = false
        end
      end
    end
  end
end
