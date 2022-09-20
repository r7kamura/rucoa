# frozen_string_literal: true

require 'logger'
require 'set'
require 'yard'

module Rucoa
  module Yard
    class DefinitionsLoader
      class << self
        # @param associations [Hash]
        # @param root_node [Rucoa::Nodes::Base]
        def call(
          associations:,
          root_node:
        )
          new(
            associations: associations,
            root_node: root_node
          ).call
        end
      end

      # @param associations [Hash]
      # @param root_node [Rucoa::Nodes::Base]
      def initialize(
        associations:,
        root_node:
      )
        @associations = associations
        @root_node = root_node
      end

      # @return [Array<Rucoa::Definition::Base>]
      def call
        [
          @root_node,
          *@root_node.descendants
        ].flat_map do |node|
          [
            DefinitionGenerators::ClassDefinitionGenerator,
            DefinitionGenerators::MethodDefinitionGenerator,
            DefinitionGenerators::ModuleDefinitionGenerator,
            DefinitionGenerators::AttributeReaderDefinitionGenerator,
            DefinitionGenerators::AttributeWriterDefinitionGenerator
          ].flat_map do |generator|
            generator.call(
              comment: comment_for(node),
              node: node
            )
          end
        end
      end

      # @return [String]
      def comment_for(node)
        @associations[node.location].map do |parser_comment|
          parser_comment.text.gsub(/^#\s*/m, '')
        end.join("\n")
      end

      module DefinitionGenerators
        class Base
          class << self
            # @param comment [String]
            # @param node [Rucoa::Nodes::Base]
            # @return [Array<Rucoa::Definitions::Base>]
            def call(
              comment:,
              node:
            )
              new(
                comment: comment,
                node: node
              ).call
            end
          end

          # @param comment [String]
          # @param node [Rucoa::Nodes::Base]
          def initialize(
            comment:,
            node:
          )
            @comment = comment
            @node = node
          end

          # @return [Array<Rucoa::Definitions::Base>]
          def call
            raise ::NotImplementedError
          end

          private

          # @return [YARD::DocstringParser]
          def docstring_parser
            @docstring_parser ||= ::YARD::Logger.instance.enter_level(::Logger::FATAL) do
              ::YARD::Docstring.parser.parse(
                @comment,
                ::YARD::CodeObjects::Base.new(:root, 'stub')
              )
            end
          end

          # @return [Array<String>]
          # @example returns annotated return types if return tag is provided
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       # @return [String]
          #       def foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0].return_types).to eq(%w[String])
          # @example returns Object if no return tag is provided
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       def foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0].return_types).to eq(%w[Object])
          def return_types
            types = docstring_parser.tags.select do |tag|
              tag.tag_name == 'return'
            end.flat_map(&:types).compact.map do |yard_type|
              Type.new(yard_type).to_rucoa_type
            end
            if types.empty?
              %w[Object]
            else
              types
            end
          end
        end

        class ClassDefinitionGenerator < Base
          # @example returns class definition for class node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       class Foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0]).to be_a(Rucoa::Definitions::ClassDefinition)
          def call
            return [] unless @node.is_a?(Nodes::ClassNode)

            [
              Definitions::ClassDefinition.new(
                fully_qualified_name: @node.fully_qualified_name,
                module_nesting: @node.module_nesting,
                source_path: @node.location.expression.source_buffer.name,
                super_class_chained_name: @node.super_class_chained_name
              )
            ]
          end
        end

        class ModuleDefinitionGenerator < Base
          # @example returns module definition for module node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       module Foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0]).to be_a(Rucoa::Definitions::ModuleDefinition)
          def call
            return [] unless @node.is_a?(Nodes::ModuleNode)

            [
              Definitions::ModuleDefinition.new(
                fully_qualified_name: @node.fully_qualified_name,
                source_path: @node.location.expression.source_buffer.name
              )
            ]
          end
        end

        class MethodDefinitionGenerator < Base
          # @example returns method definition for def node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       def foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0]).to be_a(Rucoa::Definitions::MethodDefinition)
          # @example returns method definition for defs node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       def self.foo
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[0]).to be_a(Rucoa::Definitions::MethodDefinition)
          def call
            return [] unless @node.is_a?(Nodes::DefNode) || @node.is_a?(Nodes::DefsNode)

            [
              Definitions::MethodDefinition.new(
                description: docstring_parser.to_docstring.to_s,
                kind: @node.singleton? ? :singleton : :instance,
                method_name: @node.name,
                namespace: @node.namespace,
                source_path: @node.location.expression.source_buffer.name,
                types: return_types.map do |type|
                  Types::MethodType.new(
                    parameters_string: '', # TODO
                    return_type: type
                  )
                end
              )
            ]
          end
        end

        class AttributeReaderDefinitionGenerator < Base
          READER_METHOD_NAMES = ::Set[
            'attr_accessor',
            'attr_reader'
          ].freeze

          # @example returns method definition for attr_reader node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       class Foo
          #         attr_reader :bar
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[1]).to be_a(Rucoa::Definitions::MethodDefinition)
          # @example returns method definition for attr_accessor node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       class Foo
          #         attr_accessor :bar
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions.map(&:fully_qualified_name)).to eq(
          #     %w[
          #       Foo
          #       Foo#bar
          #       Foo#bar=
          #     ]
          #   )
          def call
            return [] unless @node.is_a?(Nodes::SendNode) && READER_METHOD_NAMES.include?(@node.name)

            @node.arguments.map do |argument|
              Definitions::MethodDefinition.new(
                description: docstring_parser.to_docstring.to_s,
                kind: :instance,
                method_name: argument.value.to_s,
                namespace: @node.namespace,
                source_path: @node.location.expression.source_buffer.name,
                types: return_types.map do |type|
                  Types::MethodType.new(
                    parameters_string: '', # TODO
                    return_type: type
                  )
                end
              )
            end
          end
        end

        class AttributeWriterDefinitionGenerator < Base
          WRITER_METHOD_NAMES = ::Set[
            'attr_accessor',
            'attr_writer'
          ].freeze

          # @example returns method definition for attr_writer node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       class Foo
          #         attr_writer :bar
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions[1]).to be_a(Rucoa::Definitions::MethodDefinition)
          # @example returns method definition for attr_accessor node
          #   definitions = Rucoa::Source.new(
          #     content: <<~RUBY,
          #       class Foo
          #         attr_accessor :bar
          #       end
          #     RUBY
          #     uri: '/path/to/foo.rb'
          #   ).definitions
          #   expect(definitions.map(&:fully_qualified_name)).to eq(
          #     %w[
          #       Foo
          #       Foo#bar
          #       Foo#bar=
          #     ]
          #   )
          def call
            return [] unless @node.is_a?(Nodes::SendNode) && WRITER_METHOD_NAMES.include?(@node.name)

            @node.arguments.map do |argument|
              Definitions::MethodDefinition.new(
                description: docstring_parser.to_docstring.to_s,
                kind: :instance,
                method_name: "#{argument.value}=",
                namespace: @node.namespace,
                source_path: @node.location.expression.source_buffer.name,
                types: return_types.map do |type|
                  Types::MethodType.new(
                    parameters_string: 'value', # TODO
                    return_type: type
                  )
                end
              )
            end
          end
        end
      end
    end
  end
end
