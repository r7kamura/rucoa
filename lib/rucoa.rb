# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :DocumentStore, 'rucoa/document_store'
  autoload :Errors, 'rucoa/errors'
  autoload :Handler, 'rucoa/handler'
  autoload :MessageReader, 'rucoa/message_reader'
  autoload :MessageWriter, 'rucoa/message_writer'
  autoload :Nodes, 'rucoa/nodes'
  autoload :ParserBuilder, 'rucoa/parser_builder'
  autoload :Parser, 'rucoa/parser'
  autoload :Position, 'rucoa/position'
  autoload :Range, 'rucoa/range'
  autoload :SelectionRangeProvider, 'rucoa/selection_range_provider'
  autoload :Server, 'rucoa/server'
  autoload :Source, 'rucoa/source'
end
