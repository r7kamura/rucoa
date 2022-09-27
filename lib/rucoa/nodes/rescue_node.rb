# frozen_string_literal: true

module Rucoa
  module Nodes
    class RescueNode < Base
      # @return [Rucoa::Nodes::Base, nil]
      def body
        children[0]
      end

      # @return [Array<Rucoa::Nodes::Resbody>]
      def resbodies
        children[1..-2]
      end
    end
  end
end
