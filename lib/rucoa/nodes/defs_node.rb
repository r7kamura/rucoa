# frozen_string_literal: true

module Rucoa
  module Nodes
    class DefsNode < Base
      # @return [String]
      def name
        children[1].to_s
      end
    end
  end
end
