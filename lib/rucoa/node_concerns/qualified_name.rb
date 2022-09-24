# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module QualifiedName
      # @return [String]
      def qualified_name
        [
          name,
          *each_ancestor(:class, :constant, :module).map(&:name)
        ].reverse.join('::')
      end

      # @return [String]
      def name
        raise NotImplementedError
      end
    end
  end
end
