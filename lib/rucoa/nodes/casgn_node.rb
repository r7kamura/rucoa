# frozen_string_literal: true

module Rucoa
  module Nodes
    class CasgnNode < Base
      include NodeConcerns::FullyQualifiedName

      # @return [String]
      def name
        children[1].to_s
      end
    end
  end
end
