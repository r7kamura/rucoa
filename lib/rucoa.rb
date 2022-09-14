# frozen_string_literal: true

require_relative 'rucoa/version'

module Rucoa
  autoload :Cli, 'rucoa/cli'
  autoload :Configuration, 'rucoa/configuration'
  autoload :DefinitionArchiver, 'rucoa/definition_archiver'
  autoload :DefinitionBuilders, 'rucoa/definition_builders'
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
  autoload :Position, 'rucoa/position'
  autoload :Range, 'rucoa/range'
  autoload :RbsDocumentLoader, 'rucoa/rbs_document_loader'
  autoload :RubocopAutocorrector, 'rucoa/rubocop_autocorrector'
  autoload :RubocopConfigurationChecker, 'rucoa/rubocop_configuration_checker'
  autoload :RubocopInvestigator, 'rucoa/rubocop_investigator'
  autoload :Server, 'rucoa/server'
  autoload :Source, 'rucoa/source'
  autoload :SourceStore, 'rucoa/source_store'
  autoload :Types, 'rucoa/types'
  autoload :YardCodeObjectToDefinitionMapper, 'rucoa/yard_code_object_to_definition_mapper'
  autoload :YardGlobDocumentLoader, 'rucoa/yard_glob_document_loader'
  autoload :YardStringDocumentLoader, 'rucoa/yard_string_document_loader'
end
