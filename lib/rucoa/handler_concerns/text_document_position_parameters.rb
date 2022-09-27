# frozen_string_literal: true

module Rucoa
  module HandlerConcerns
    module TextDocumentPositionParameters
      private

      # @return [Rucoa::Nodes::Base, nil]
      def node
        return unless position
        return unless source

        @node ||= source.node_at(position)
      end

      # @return [String, nil]
      def parameter_position
        @parameter_position ||= request.dig('params', 'position')
      end

      # @return [Rucoa::Position, nil]
      def position
        return unless parameter_position

        @position ||= Position.from_vscode_position(parameter_position)
      end
    end
  end
end
