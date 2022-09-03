# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :Handler, 'rucoa/handler'
  autoload :Server, 'rucoa/server'
end
