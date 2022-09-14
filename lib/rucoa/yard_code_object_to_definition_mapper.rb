# frozen_string_literal: true

require 'yard'

module Rucoa
  class YardCodeObjectToDefinitionMapper
    class << self
      # @param code_object [YARD::CodeObjects::Base]
      # @param path [String] This must be passed if the path is not available from code object.
      # @return [Rucoa::Definitions::Base, nil]
      def call(code_object, path: code_object.file)
        new(code_object, path: path).call
      end
    end

    # @param code_object [YARD::CodeObjects::Base]
    # @param path [String]
    def initialize(code_object, path:)
      @code_object = code_object
      @path = path
    end

    # @return [Rucoa::Definitions::Base, nil]
    def call
      case @code_object
      when ::YARD::CodeObjects::MethodObject
        DefinitionBuilders::YardMethodDefinitionBuilder.call(
          code_object: @code_object,
          path: @path
        )
      end
    end
  end
end
