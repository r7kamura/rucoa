# frozen_string_literal: true

module Rucoa
  module Nodes
    class LvasgnNode < Base
      # @return [String]
      def name
        children[0].to_s
      end
    end
  end
end
