# frozen_string_literal: true

module Rucoa
  module Definitions
    class Base
      # @return [String]
      def source_path
        raise ::NotImplementedError
      end
    end
  end
end
