# frozen_string_literal: true

require 'logger'
require 'yard'

module Rucoa
  class YardGlobDocumentLoader
    class << self
      # @param globs [Array<String>]
      # @return [Array<Rucoa::Definitions::Base>]
      def call(globs:)
        new(
          globs: globs
        ).call
      end
    end

    # @param globs [String]
    def initialize(globs:)
      @globs = globs
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def call
      code_objects.filter_map do |code_object|
        case code_object
        when ::YARD::CodeObjects::MethodObject
          DefinitionBuilders::YardMethodDefinitionBuilder.call(
            code_object: code_object,
            path: code_object.file
          )
        end
      end
    end

    private

    # @return [Array<YARD::CodeObjects::Base>]
    def code_objects
      ::YARD::Logger.instance.enter_level(::Logger::FATAL) do
        ::YARD::Registry.clear
        ::YARD.parse(@globs)
        ::YARD::Registry.all
      end
    end
  end
end