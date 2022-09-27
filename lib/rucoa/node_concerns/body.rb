# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module Body
      # @return [Rucoa::Nodes::BeginNode, nil]
      def body
        children.last
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def body_children
        case body
        when Nodes::BeginNode
          body.children
        when nil
          []
        else
          [body]
        end
      end
    end
  end
end
