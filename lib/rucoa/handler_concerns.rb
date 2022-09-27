# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    autoload :ConfigurationRequestable, 'rucoa/handler_concerns/configuration_requestable'
    autoload :DiagnosticsPublishable, 'rucoa/handler_concerns/diagnostics_publishable'
    autoload :TextDocumentPositionParameters, 'rucoa/handler_concerns/text_document_position_parameters'
  end
end
