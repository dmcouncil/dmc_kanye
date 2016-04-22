raise "Kanye is not allowed in this environment." unless Rails.env.test?

require "dmc_kanye/version"

require_relative 'dmc_kanye/config'
require_relative 'dmc_kanye/driver_helpers'
require_relative 'dmc_kanye/imma_let_you_finish'
