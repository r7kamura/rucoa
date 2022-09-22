# frozen_string_literal: true

module Rucoa
  module Nodes
    class ModuleNode < Base
      include NodeConcerns::Body
      include NodeConcerns::NameFullyQualifiable

      # @return [String]
      def name
        const_node.name
      end

      private

      # @return [Rucoa::Nodes::ConstNode]
      def const_node
        children[0]
      end
    end
  end
end
