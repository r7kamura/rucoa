# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentCompletionHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters

      COMPLETION_ITEM_KIND_FOR_TEXT = 1
      COMPLETION_ITEM_KIND_FOR_METHOD = 2
      COMPLETION_ITEM_KIND_FOR_FUNCTION = 3
      COMPLETION_ITEM_KIND_FOR_CONSTRUCTOR = 4
      COMPLETION_ITEM_KIND_FOR_FIELD = 5
      COMPLETION_ITEM_KIND_FOR_VARIABLE = 6
      COMPLETION_ITEM_KIND_FOR_CLASS = 7
      COMPLETION_ITEM_KIND_FOR_INTERFACE = 8
      COMPLETION_ITEM_KIND_FOR_MODULE = 9
      COMPLETION_ITEM_KIND_FOR_PROPERTY = 10
      COMPLETION_ITEM_KIND_FOR_UNIT = 11
      COMPLETION_ITEM_KIND_FOR_VALUE = 12
      COMPLETION_ITEM_KIND_FOR_ENUM = 13
      COMPLETION_ITEM_KIND_FOR_KEYWORD = 14
      COMPLETION_ITEM_KIND_FOR_SNIPPET = 15
      COMPLETION_ITEM_KIND_FOR_COLOR = 16
      COMPLETION_ITEM_KIND_FOR_FILE = 17
      COMPLETION_ITEM_KIND_FOR_REFERENCE = 18
      COMPLETION_ITEM_KIND_FOR_FOLDER = 19
      COMPLETION_ITEM_KIND_FOR_ENUM_MEMBER = 20
      COMPLETION_ITEM_KIND_FOR_CONSTANT = 21
      COMPLETION_ITEM_KIND_FOR_STRUCT = 22
      COMPLETION_ITEM_KIND_FOR_EVENT = 23
      COMPLETION_ITEM_KIND_FOR_OPERATOR = 24
      COMPLETION_ITEM_KIND_FOR_TYPE_PARAMETER = 25

      EXAMPLE_IDENTIFIER = 'a'
      private_constant :EXAMPLE_IDENTIFIER

      def call
        respond(completion_items)
      end

      private

      # @return [Array<String>]
      def callable_method_definitions
        receiver_types.flat_map do |type|
          definition_store.instance_method_definitions_of(type)
        end
      end

      # @return [Array<String>]
      def callable_method_names
        callable_method_definitions.map(&:method_name).uniq
      end

      # @return [Array<String>]
      def completable_constant_names
        referrable_constant_names.select do |constant_name|
          constant_name.start_with?(completion_head)
        end.sort
      end

      # @return [Array<String>]
      def completable_method_names
        callable_method_names.select do |method_name|
          method_name.start_with?(completion_head)
        end.sort
      end

      # @return [String] e.g. "SE" to `File::SE|`, "ba" to `foo.ba|`
      def completion_head
        @completion_head ||=
          if @repaired
            ''
          else
            node.name
          end
      end

      # @return [Array<Hash>, nil]
      def completion_items
        return unless responsible?

        case node
        when Nodes::ConstNode
          completion_items_for_constant
        when Nodes::SendNode
          if node.location.dot&.is?('::')
            completion_items_for_constant
          else
            completion_items_for_method
          end
        else
          []
        end
      end

      # @return [Array<Hash>]
      def completion_items_for_constant
        completable_constant_names.map do |constant_name|
          {
            kind: COMPLETION_ITEM_KIND_FOR_CONSTANT,
            label: constant_name,
            textEdit: {
              newText: constant_name,
              range: range.to_vscode_range
            }
          }
        end
      end

      # @return [Array<Hash>]
      def completion_items_for_method
        completable_method_names.map do |method_name|
          {
            kind: COMPLETION_ITEM_KIND_FOR_METHOD,
            label: method_name,
            textEdit: {
              newText: method_name,
              range: range.to_vscode_range
            }
          }
        end
      end

      # @return [String] e.g. "Foo::Bar" to `Foo::Bar.baz|`.
      def constant_namespace
        node.each_child_node(:const).map(&:name).reverse.join('::')
      end

      # @return [Rucoa::Node, nil]
      def node
        @node ||=
          if source.failed_to_parse?
            repair
            repaired_node
          else
            normal_node
          end
      end

      # @return [Rucoa::Node, nil]
      def normal_node
        source.node_at(position)
      end

      # @return [Rucoa::Range]
      def range
        @range ||=
          if @repaired
            position.to_range
          else
            Range.from_parser_range(
              case node
              when Nodes::SendNode
                node.location.selector
              else
                node.location.expression
              end
            )
          end
      end

      # @return [Array<String>]
      def receiver_types
        NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).method_receiver_types
      end

      def referrable_constant_names
        definition_store.constant_definitions_under(constant_namespace).map(&:name).uniq
      end

      # @return [void]
      def repair
        @repaired = true
      end

      # @return [String]
      def repaired_content
        source.content.dup.insert(
          position.to_index_of(source.content),
          EXAMPLE_IDENTIFIER
        )
      end

      # @return [Rucoa::Node, nil]
      def repaired_node
        repaired_source.node_at(position)
      end

      # @return [Rucoa::Source]
      def repaired_source
        Source.new(
          content: repaired_content,
          uri: source.uri
        )
      end

      # @return [Boolean]
      def responsible?
        configuration.enables_completion? &&
          !source.nil?
      end

      # @return [Rucoa::Source, nil]
      def source
        @source ||= source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end
    end
  end
end
