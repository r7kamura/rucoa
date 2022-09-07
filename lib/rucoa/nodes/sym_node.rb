# frozen_string_literal: true

module Rucoa
  module Nodes
    class SymNode < Base
      # @return [String]
      def value
        children[0]
      end
    end
  end
end
