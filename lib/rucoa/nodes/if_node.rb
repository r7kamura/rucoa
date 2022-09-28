# frozen_string_literal: true

module Rucoa
  module Nodes
    class IfNode < Base
      # @return [Rucoa::Nodes::Base, nil]
      def branch_else
        children[2]
      end

      # @return [Rucoa::Nodes::Base, nil]
      def branch_if
        children[1]
      end

      # @return [Rucoa::Nodes::Base]
      def condition
        children[0]
      end

      # @return [Rucoa::Nodes::IfNode, nil]
      def elsif
        branch_else if branch_else.is_a?(Nodes::IfNode)
      end

      # @return [Boolean]
      def elsif?
        parent.is_a?(Nodes::IfNode) && eql?(parent.elsif)
      end
    end
  end
end
