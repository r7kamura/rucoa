# frozen_string_literal: true

module Rucoa
  module Nodes
    class ArgsNode < Base
      include ::Enumerable

      # @note For `Enumerable`.
      def each(&block)
        children.each(&block)
      end
    end
  end
end
