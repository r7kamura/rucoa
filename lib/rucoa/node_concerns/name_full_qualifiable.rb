# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    module NameFullQualifiable
      # @return [String]
      def full_qualified_name
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
