# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module Rescue
      # @return [Rucoa::Nodes::EnsureNode, nil]
      def ensure
        return unless body.is_a?(Nodes::EnsureNode)

        body
      end

      # @return [Rucoa::Nodes::RescueNode, nil]
      def rescue
        return unless body.is_a?(Nodes::RescueNode)

        body
      end
    end
  end
end
