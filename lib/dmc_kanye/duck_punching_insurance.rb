require 'capybara'
require 'capybara/poltergeist'
require 'capybara/poltergeist/version'

unless Capybara::VERSION == "2.4.4"
  raise "Kanye specifically monkey-patched version 2.4.4 of Capybara. "\
        "You have version #{Capybara::VERSION}. "\
        "Please upgrade the monkey patches along with the gem."
end

unless Capybara::Poltergeist::VERSION == "1.5.1"
  raise "Kanye specifically monkey-patched version 1.5.1 of Poltergeist. "\
        "You have version #{Capybara::Poltergeist::VERSION}. "\
        "Please upgrade the monkey patches along with the gem."
end
