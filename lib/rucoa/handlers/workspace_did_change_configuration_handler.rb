# frozen_string_literal: true

module Rucoa
  module Handlers
    class WorkspaceDidChangeConfigurationHandler < Base
      include HandlerConcerns::ConfigurationRequestable

      def call
        request_workspace_configuration
      end
    end
  end
end
