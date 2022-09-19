# frozen_string_literal: true

module Rucoa
  module Nodes
    class DefsNode < Base
      # @return [String]
      def fully_qualified_name
        [
          namespace,
          method_marker,
          name
        ].join
      end

      # @return [String]
      def name
        children[1].to_s
      end

      # @return [Boolean]
      def singleton?
        true
      end

      private

      # @return [String]
      def method_marker
        '.'
      end
    end
  end
end
