# frozen_string_literal: true

module Rucoa
  module Handlers
    autoload :Base, 'rucoa/handlers/base'
    autoload :ExitHandler, 'rucoa/handlers/exit_handler'
    autoload :InitializeHandler, 'rucoa/handlers/initialize_handler'
    autoload :InitializedHandler, 'rucoa/handlers/initialized_handler'
    autoload :ShutdownHandler, 'rucoa/handlers/shutdown_handler'
    autoload :TextDocumentCodeActionHandler, 'rucoa/handlers/text_document_code_action_handler'
    autoload :TextDocumentCompletionHandler, 'rucoa/handlers/text_document_completion_handler'
    autoload :TextDocumentDefinitionHandler, 'rucoa/handlers/text_document_definition_handler'
    autoload :TextDocumentDidChangeHandler, 'rucoa/handlers/text_document_did_change_handler'
    autoload :TextDocumentDidCloseHandler, 'rucoa/handlers/text_document_did_close_handler'
    autoload :TextDocumentDidOpenHandler, 'rucoa/handlers/text_document_did_open_handler'
    autoload :TextDocumentDocumentSymbolHandler, 'rucoa/handlers/text_document_document_symbol_handler'
    autoload :TextDocumentFormattingHandler, 'rucoa/handlers/text_document_formatting_handler'
    autoload :TextDocumentHoverHandler, 'rucoa/handlers/text_document_hover_handler'
    autoload :TextDocumentRangeFormattingHandler, 'rucoa/handlers/text_document_range_formatting_handler'
    autoload :TextDocumentSelectionRangeHandler, 'rucoa/handlers/text_document_selection_range_handler'
    autoload :TextDocumentSignatureHelpHandler, 'rucoa/handlers/text_document_signature_help_handler'
    autoload :WorkspaceDidChangeConfigurationHandler, 'rucoa/handlers/workspace_did_change_configuration_handler'
  end
end
