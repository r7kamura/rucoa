# frozen_string_literal: true

require 'logger'
require 'yard'

module Rucoa
  module Yard
    class DefinitionsLoader
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
        #   definitions = Rucoa::Yard::DefinitionsLoader.load_string(
        #     content: content,
        #     path: '/path/to/foo.rb'
        #   )
        #   expect(definitions.size).to eq(1)
        #   expect(definitions.first.full_qualified_name).to eq('Foo#foo')
        #   expect(definitions.first.source_path).to eq('/path/to/foo.rb')
        #   expect(definitions.first.description).to eq('Return given argument as an Integer.')
        #   expect(definitions.first.return_types).to eq(%w[Integer])
        def load_string(content:, path:)
          ::YARD::Registry.clear
          quietly do
            ::YARD.parse_string(content)
          end
          ::YARD::Registry.all.filter_map do |code_object|
            DefinitionMapper.call(code_object, path: path)
          end
        end

        # @param globs [String]
        # @return [Array<Rucoa::Definitions::Base>]
        def load_globs(globs:)
          ::YARD::Registry.clear
          quietly do
            ::YARD.parse(globs)
          end
          ::YARD::Registry.all.filter_map do |code_object|
            DefinitionMapper.call(code_object)
          end
        end

        private

        def quietly(&block)
          ::YARD::Logger.instance.enter_level(::Logger::FATAL, &block)
        end
      end
    end
  end
end
