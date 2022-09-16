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
        #   expect(definitions.size).to eq(2)
        #   expect(definitions[1].full_qualified_name).to eq('Foo#foo')
        #   expect(definitions[1].source_path).to eq('/path/to/foo.rb')
        #   expect(definitions[1].description).to eq('Return given argument as an Integer.')
        #   expect(definitions[1].return_types).to eq(%w[Integer])
        def load_string(content:, path:)
          load(path: path) do
            ::YARD.parse_string(content)
          end
        end

        # @param globs [String]
        # @return [Array<Rucoa::Definitions::Base>]
        def load_globs(globs:)
          load do
            ::YARD.parse(globs)
          end
        end

        private

        # @param code_object [YARD::CodeObjects::Base]
        # @param path [String, nil]
        # @return [Rucoa::Definitions::Base, nil]
        def map(code_object, path:)
          case code_object
          when ::YARD::CodeObjects::ClassObject
            Definitions::ClassDefinition.new(
              full_qualified_name: code_object.path,
              source_path: path || code_object.file,
              super_class_name: code_object.superclass.to_s
            )
          when ::YARD::CodeObjects::ModuleObject
            Definitions::ModuleDefinition.new(
              full_qualified_name: code_object.path,
              source_path: path || code_object.file
            )
          when ::YARD::CodeObjects::MethodObject
            MethodDefinitionMapper.call(code_object, path: path)
          end
        end

        # @param path [String, nil]
        # @return [Array<Rucoa::Definitions::Base>]
        def load(path: nil, &block)
          ::YARD::Registry.clear
          quietly(&block)
          ::YARD::Registry.all.filter_map do |code_object|
            map(code_object, path: path)
          end
        end

        def quietly(&block)
          ::YARD::Logger.instance.enter_level(::Logger::FATAL, &block)
        end
      end
    end
  end
end
