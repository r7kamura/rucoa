# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :Errors, 'rucoa/errors'
  autoload :DiagnosticProvider, 'rucoa/diagnostic_provider'
  autoload :MessageReader, 'rucoa/message_reader'
  autoload :MessageWriter, 'rucoa/message_writer'
  autoload :Nodes, 'rucoa/nodes'
  autoload :ParserBuilder, 'rucoa/parser_builder'
  autoload :Parser, 'rucoa/parser'
  autoload :Position, 'rucoa/position'
  autoload :Range, 'rucoa/range'
  autoload :RubocopRunner, 'rucoa/rubocop_runner'
  autoload :SelectionRangeProvider, 'rucoa/selection_range_provider'
  autoload :Server, 'rucoa/server'
  autoload :Source, 'rucoa/source'
  autoload :SourceStore, 'rucoa/source_store'
end
