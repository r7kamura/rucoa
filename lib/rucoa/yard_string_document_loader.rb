# frozen_string_literal: true

require 'logger'
require 'yard'

module Rucoa
  class YardStringDocumentLoader
    class << self
      # @param content [String]
      # @return [Array<Rucoa::Definitions::Base>]
      # @example returns method definitions from Ruby source code
      #   content = <<~RUBY
      #     class Foo
      #       # Return given argument as an Integer.
      #       # @param bar [String]
      #       # @return [Integer]
      #       def foo(bar)
      #         bar.to_i
      #       end
      #     end
      #   RUBY
      #   definitions = Rucoa::YardStringDocumentLoader.call(
      #     content: content,
      #     path: '/path/to/foo.rb'
      #   )
      #   expect(definitions.size).to eq(1)
      #   expect(definitions.first.full_qualified_name).to eq('Foo#foo')
      #   expect(definitions.first.source_path).to eq('/path/to/foo.rb')
      #   expect(definitions.first.description).to eq('Return given argument as an Integer.')
      #   expect(definitions.first.return_types).to eq(%w[Integer])
      def call(content:, path:)
        new(
          content: content,
          path: path
        ).call
      end
    end

    # @param content [String]
    # @param path [String]
    def initialize(content:, path:)
      @content = content
      @path = path
    end

    # @return [Array<Rucoa::Definitions::Base>]
    def call
      code_objects.filter_map do |code_object|
        case code_object
        when ::YARD::CodeObjects::MethodObject
          DefinitionBuilders::YardMethodDefinitionBuilder.call(
            code_object: code_object,
            path: @path
          )
        end
      end
    end

    private

    # @return [Array<YARD::CodeObjects::Base>]
    def code_objects
      ::YARD::Logger.instance.enter_level(::Logger::FATAL) do
        ::YARD::Registry.clear
        ::YARD.parse_string(@content)
        ::YARD::Registry.all
      end
    end
  end
end
