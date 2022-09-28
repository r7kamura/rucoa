# frozen_string_literal: true

module Rucoa
  module Nodes
    class EnsureNode < Base
      # @return [Rucoa::Nodes::Base, nil]
      def body
        children[0]
      end

      # @return [Rucoa::Nodes::RescueNode, nil]
      def rescue
        return unless body.is_a?(Nodes::RescueNode)

        body
      end
    end
  end
end
