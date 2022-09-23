# frozen_string_literal: true

module Rucoa
  module Yard
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

        # @return [String]
        def description
          docstring_parser.to_docstring.to_s
        end

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
    end
  end
end
