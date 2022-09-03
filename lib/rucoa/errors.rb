# frozen_string_literal: true

module Rucoa
  module Errors
    class Base < ::StandardError
    end

    class ContentLengthHeaderNotFound < Base
      def initialize
        super('Content-Length header not found.')
      end
    end

    class BodyNotFound < Base
      def initialize
        super('Body not found.')
      end
    end
  end
end
