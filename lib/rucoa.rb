# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :Configuration, 'rucoa/configuration'
  autoload :DefinitionArchiver, 'rucoa/definition_archiver'
  autoload :Definitions, 'rucoa/definitions'
  autoload :DefinitionStore, 'rucoa/definition_store'
  autoload :Errors, 'rucoa/errors'
  autoload :HandlerConcerns, 'rucoa/handler_concerns'
  autoload :Handlers, 'rucoa/handlers'
  autoload :MessageReader, 'rucoa/message_reader'
  autoload :MessageWriter, 'rucoa/message_writer'
  autoload :NodeConcerns, 'rucoa/node_concerns'
  autoload :NodeInspector, 'rucoa/node_inspector'
  autoload :Nodes, 'rucoa/nodes'
  autoload :Parser, 'rucoa/parser'
  autoload :ParserBuilder, 'rucoa/parser_builder'
  autoload :ParseResult, 'rucoa/parse_result'
  autoload :Position, 'rucoa/position'
  autoload :Range, 'rucoa/range'
  autoload :Rbs, 'rucoa/rbs'
  autoload :Rubocop, 'rucoa/rubocop'
  autoload :Server, 'rucoa/server'
  autoload :Source, 'rucoa/source'
  autoload :SourceStore, 'rucoa/source_store'
  autoload :Types, 'rucoa/types'
  autoload :Yard, 'rucoa/yard'
end
