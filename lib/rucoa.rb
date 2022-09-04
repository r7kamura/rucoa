# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :CodeActionProvider, 'rucoa/code_action_provider'
  autoload :DiagnosticProvider, 'rucoa/diagnostic_provider'
  autoload :Errors, 'rucoa/errors'
  autoload :FormattingProvider, 'rucoa/formatting_provider'
  autoload :MessageReader, 'rucoa/message_reader'
  autoload :MessageWriter, 'rucoa/message_writer'
  autoload :Nodes, 'rucoa/nodes'
  autoload :Parser, 'rucoa/parser'
  autoload :ParserBuilder, 'rucoa/parser_builder'
  autoload :Position, 'rucoa/position'
  autoload :Range, 'rucoa/range'
  autoload :RubocopAutocorrector, 'rucoa/rubocop_autocorrector'
  autoload :RubocopInvestigator, 'rucoa/rubocop_investigator'
  autoload :SelectionRangeProvider, 'rucoa/selection_range_provider'
  autoload :Server, 'rucoa/server'
  autoload :Source, 'rucoa/source'
  autoload :SourceStore, 'rucoa/source_store'
end
