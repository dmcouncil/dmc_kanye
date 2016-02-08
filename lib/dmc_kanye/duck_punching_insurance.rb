require 'capybara'
require 'capybara/poltergeist'
require 'capybara/poltergeist/version'

unless Capybara::Poltergeist::VERSION == "1.5.1"
  raise "Kanye specifically monkey-patched version 1.5.1 of Poltergeist. "\
        "You have version #{Capybara::Poltergeist::VERSION}. "\
        "Please upgrade the monkey patches along with the gem."
end
