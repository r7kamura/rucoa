# frozen_string_literal: true

module Rucoa
  module Nodes
    class ConstNode < Base
      # @return [String]
      def name
        children[1].to_s
      end
    end
  end
end
