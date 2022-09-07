# frozen_string_literal: true

module Rucoa
  module Nodes
    class SendNode < Base
      # @return [Array<Rucoa::Nodes::Base>]
      def arguments
        children[2..]
      end

      # @return [String]
      def name
        children[1].to_s
      end
    end
  end
end
