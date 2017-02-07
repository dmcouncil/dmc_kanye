# DMC Kanye

[![Code Climate](https://codeclimate.com/github/dmcouncil/dmc_kanye/badges/gpa.svg)](https://codeclimate.com/github/dmcouncil/dmc_kanye)

Kanye improves Capybara's synchronization algorithm by letting the browser finish before the test keeps going.  By doing this, Kanye also helps you tailor the swiftness of your feature specs.

## How Kanye Works

When a Capybara test is run with a JavaScript driver, the two processes can easily get out of sync which causes intermittent, difficult-to-reproduce test failures.

### How Timing Failures Happen

For example, imagine a feature where a user clicks a "details" button, which causes a pane to slide down containing the extra information.  The Capybara test may want to:

  * click the details button
  * expect that "foo bar baz" is showing in the details pane

The Ruby process will apply the expectation immediately after clicking the button; however, the browser may need some time to:

  * send an ajax request to the server to fetch the details
  * do a fancy slide-down animation

Since the details wouldn't be visible yet, the Cabybara test will fail.

### A Stupid Way to Solve Timing Failures

You could simply `sleep 20` after every single command you send to the browser, which should give it plenty of time to finish whatever it is doing and catch up to the Ruby process.

Obviously, this would make the tests unbearably slow, so a good solution to timing failures should balance speed and robustness well.

### Capybara's Approach to Timing Issues

Capybara's way of solving timing issues, [which can be found here in its code](https://github.com/jnicklas/capybara/blob/2.4.4/lib/capybara/node/base.rb#L43), is basically this:

  * Just do everything as if timing issues don't exist.
  * If we do X and  get a `Capybara::ElementNotFound` error, it could be because the browser has not caught up to the Ruby process.  In this case, wait for the browser to catch up like so:
    * Sleep for 0.05 seconds.
    * Do X again.
    * If X succeeds you are done.
    * If X fails, try again.
    * Repeat until `Capybara.default_wait_time` seconds have passed.

### Some Problems with Capybara's Approach

**The "Does Not Exist" Gotcha** -- `!page.has_css?('.error-notice')`, while intuitive to write, will lead to an incorrectly written test. [Read more here.](https://github.com/jnicklas/capybara#asynchronous-javascript-ajax-and-friends)

**JavaScript Bleeding** -- it's possible that the browser is still executing some leftover ajax or other JavaScript after one test example has ended and during the execution of a new test example.  While this rarely happens, when it does, it is very hard to troubleshoot the cause.

**Slower Specs** -- every time we have an example that expects an element to *not* be present, it is forced to wait the entire `Capybara.default_wait_time`.  As the number of spec examples grow, this adds up.  You can't simply choose a very small `Capybara.default_wait_time`, because this will lead to instability of test results.

### Kanye's Approach to Timing Issues

Kanye's strategy is, instead of sleeping and waiting for things to happen, to take more control.  This will lead to tests that are *both* faster and more robust.

It's easiest to think of Kanye as a wrapper.  Every single time the browser is asked to do X, it is wrapped like this:

  * Imma let you finish
  * now do X
  * Imma let you finish

"Imma let you finish" means that Kanye closely watches the browser for indications that it is busy, waiting until it is finished before allowing the Capybara process to continue.

More specifically, Kanye does the following:

  * waits for all ajax to complete
  * if the browser URL has changed, triggers some JavaScript code that disables all transitions on the page

That last point is important to note.  Transitions (CSS transitions, jQuery transitions, etc.) take time, which causes the Capybara process to get ahead of the browser process.  There is no reliable way to know whether the browser is currently running any transitions, so the strategy is to disable them.  Take note of two things:

  * you have to supply the JavaScript code snippet that disables transitions
  * this means the test is not totally "pure" since it is disabling some production code (transitions)



## Basic Usage

### Setup

Kanye requires poltergeist and jQuery.

Add Kanye to your gemfile (if you have a test group, you can put it there):

    gem 'dmc_kanye'

Require Kanye in your spec_helper.rb:

    require 'dmc_kanye'

Configure Kanye with JavaScript that will disable transitions:

    DmcKanye::Config.script_to_disable_transitions = "(typeof jQuery === 'undefined') ? false : jQuery('.fade').removeClass('fade')"

Kanye can't predict which kind of transitions you will use or how to disable them, so you have to supply the JavaScript that will disable transitions.  This transition-disabling JavaScript is executed on the browser every time the browser URL changes.

Set Capybara's wait time lower to speed up your specs:

    Capybara.default_wait_time = 0.5

Configure Kanye's default wait time:

    DmcKanye::Config.default_wait_time = 0.5

The Kanye default wait time will be used when poltergeist is active (meaning :js => true for that spec).  Otherwise, you will be using the Rack::Test driver which will use the Capybara default wait time.  Because Kanye keeps a more controlled watch on what the browser is doing, there is less guess-work and so Kanye's default wait time can be lower than Capybara's.

### Usage in Specs

You generally don't have to think about timing issues as you write your specs.  Even if you are writing a spec that makes sure an error message does not appear, Kanye will be waiting for the ajax to finish so you don't have to do anything special in your spec.

However, there are a couple of situations that may confuse Kanye:

  * you have a complex JavaScript chain of events started by an ajax completion event (for example, ajax that reloads the current page when completing)
  * anytime the browser is busy for longer than `Capybara.default_wait_time` and the page has already finished loading and all ajax has completed (for example, you have a JavaScript function that walks the dom and does something very time-consuming to each element)

In those (hopefully rare) situations, it is recommended that you write your own code into that test to deal with the timing issue, even if it ends up being a dumb `sleep` statement.  Kanye provides some [helper methods](driver_helpers.rb) to make your job easier and help you avoid those `sleep` statements.

## Contributors

DMC Kanye was originally developed by [Wyatt Greene]() and is maintained by [District Management Group][1].

## A note about the name

There are more than a few "Kanye" gems in the world already, but the name was just too good to pass up. For open-source release, Kanye was "namespaced" with the company where it was originally developed, The District Management Council ([now District Management Group][1]).

[1]: https://dmgroupK12.com/
