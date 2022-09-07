# frozen_string_literal: true

module Rucoa
  module Handlers
    autoload :Base, 'rucoa/handlers/base'
    autoload :InitializeHandler, 'rucoa/handlers/initialize_handler'
    autoload :InitializedHandler, 'rucoa/handlers/initialized_handler'
    autoload :TextDocumentCodeActionHandler, 'rucoa/handlers/text_document_code_action_handler'
    autoload :TextDocumentDidChangeHandler, 'rucoa/handlers/text_document_did_change_handler'
    autoload :TextDocumentDidOpenHandler, 'rucoa/handlers/text_document_did_open_handler'
    autoload :TextDocumentDocumentSymbolHandler, 'rucoa/handlers/text_document_document_symbol_handler'
    autoload :TextDocumentFormattingHandler, 'rucoa/handlers/text_document_formatting_handler'
    autoload :TextDocumentRangeFormattingHandler, 'rucoa/handlers/text_document_range_formatting_handler'
    autoload :TextDocumentSelectionRangeHandler, 'rucoa/handlers/text_document_selection_range_handler'
    autoload :WorkspaceDidChangeConfigurationHandler, 'rucoa/handlers/workspace_did_change_configuration_handler'
  end
end
