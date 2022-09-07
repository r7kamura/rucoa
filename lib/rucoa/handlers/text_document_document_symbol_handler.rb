# frozen_string_literal: true

require 'set'

module Rucoa
  module Handlers
    class TextDocumentDocumentSymbolHandler < Base
      DOCUMENT_SYMBOL_KIND_FOR_FILE = 1
      DOCUMENT_SYMBOL_KIND_FOR_MODULE = 2
      DOCUMENT_SYMBOL_KIND_FOR_NAMESPACE = 3
      DOCUMENT_SYMBOL_KIND_FOR_PACKAGE = 4
      DOCUMENT_SYMBOL_KIND_FOR_CLASS = 5
      DOCUMENT_SYMBOL_KIND_FOR_METHOD = 6
      DOCUMENT_SYMBOL_KIND_FOR_PROPERTY = 7
      DOCUMENT_SYMBOL_KIND_FOR_FIELD = 8
      DOCUMENT_SYMBOL_KIND_FOR_CONSTRUCTOR = 9
      DOCUMENT_SYMBOL_KIND_FOR_ENUM = 10
      DOCUMENT_SYMBOL_KIND_FOR_INTERFACE = 11
      DOCUMENT_SYMBOL_KIND_FOR_FUNCTION = 12
      DOCUMENT_SYMBOL_KIND_FOR_VARIABLE = 13
      DOCUMENT_SYMBOL_KIND_FOR_CONSTANT = 14
      DOCUMENT_SYMBOL_KIND_FOR_STRING = 15
      DOCUMENT_SYMBOL_KIND_FOR_NUMBER = 16
      DOCUMENT_SYMBOL_KIND_FOR_BOOLEAN = 17
      DOCUMENT_SYMBOL_KIND_FOR_ARRAY = 18
      DOCUMENT_SYMBOL_KIND_FOR_OBJECT = 19
      DOCUMENT_SYMBOL_KIND_FOR_KEY = 20
      DOCUMENT_SYMBOL_KIND_FOR_NULL = 21
      DOCUMENT_SYMBOL_KIND_FOR_ENUMMEMBER = 22
      DOCUMENT_SYMBOL_KIND_FOR_STRUCT = 23
      DOCUMENT_SYMBOL_KIND_FOR_EVENT = 24
      DOCUMENT_SYMBOL_KIND_FOR_OPERATOR = 25
      DOCUMENT_SYMBOL_KIND_FOR_TYPEPARAMETER = 26

      # @return [Set<String>]
      ATTRIBUTE_METHOD_NAMES = ::Set[
        'attr_accessor',
        'attr_reader',
        'attr_writer',
      ]

      def call
        return unless respondable?

        respond(document_symbols)
      end

      private

      # @return [Array<Hash>]
      def document_symbols
        visit(source.root_node)
        document_symbol_stack.first[:children]
      end

      # @param node [Rucoa::Nodes::Base]
      # @return [void]
      def visit(node)
        document_symbols = create_document_symbols_for(node)
        document_symbol_stack.last[:children].push(*document_symbols)
        with_document_symbol_stack(document_symbols.first) do
          with_singleton_class_stack(node) do
            node.each_child_node do |child_node|
              visit(child_node)
            end
          end
        end
      end

      # @param document_symbol [Hash, nil]
      # @return [void]
      def with_document_symbol_stack(document_symbol)
        unless document_symbol
          yield
          return
        end

        document_symbol_stack.push(document_symbol)
        yield
        document_symbol_stack.pop
      end

      # @param node [Rucoa::Nodes::Base]
      def with_singleton_class_stack(node)
        unless node.is_a?(Rucoa::Nodes::SclassNode)
          yield
          return
        end

        singleton_class_stack.push(node)
        yield
        singleton_class_stack.pop
      end

      # @param node [Rucoa::Nodes::Base]
      # @return [Array<Hash>]
      def create_document_symbols_for(node)
        case node
        when Nodes::CasgnNode
          create_document_symbols_for_casgn(node)
        when Nodes::ClassNode
          create_document_symbols_for_class(node)
        when Nodes::DefNode
          create_document_symbols_for_def(node)
        when Nodes::DefsNode
          create_document_symbols_for_defs(node)
        when Nodes::ModuleNode
          create_document_symbols_for_module(node)
        when Nodes::SendNode
          create_document_symbols_for_send(node)
        else
          []
        end
      end

      # @param node [Rucoa::Nodes::CasgnNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_casgn(node)
        [
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_CONSTANT,
            name: node.name,
            range: Range.from_parser_range(node.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(node.location.name).to_vscode_range
          }
        ]
      end

      # @param node [Rucoa::Nodes::ClassNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_class(node)
        [
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_CLASS,
            name: node.name,
            range: Range.from_parser_range(node.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(node.location.name).to_vscode_range
          }
        ]
      end

      # @param node [Rucoa::Nodes::ModuleNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_module(node)
        [
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_MODULE,
            name: node.name,
            range: Range.from_parser_range(node.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(node.location.name).to_vscode_range
          }
        ]
      end

      # @param node [Rucoa::Nodes::DefNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_def(node)
        [
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_METHOD,
            name: singleton_class_stack.empty? ? "##{node.name}" : ".#{node.name}",
            range: Range.from_parser_range(node.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(node.location.name).to_vscode_range
          }
        ]
      end

      # @param node [Rucoa::Nodes::DefNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_defs(node)
        [
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_METHOD,
            name: ".#{node.name}",
            range: Range.from_parser_range(node.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(node.location.name).to_vscode_range
          }
        ]
      end

      # @param node [Rucoa::Nodes::SendNode]
      # @return [Array<Hash>]
      def create_document_symbols_for_send(node)
        return [] unless ATTRIBUTE_METHOD_NAMES.include?(node.name)

        simple_types = ::Set[
          :str,
          :sym
        ]
        node.arguments.select do |argument|
          simple_types.include?(argument.type)
        end.map do |argument|
          {
            children: [],
            kind: DOCUMENT_SYMBOL_KIND_FOR_FIELD,
            name: argument.value.to_s,
            range: Range.from_parser_range(argument.location.expression).to_vscode_range,
            selectionRange: Range.from_parser_range(argument.location.expression).to_vscode_range
          }
        end
      end

      # @return [Boolean]
      def respondable?
        configuration.enables_document_symbol? && source
      end

      # @return [Rucoa::Source]
      def source
        @source ||= @server.source_store.get(uri)
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Arrah<Hash>]
      def document_symbol_stack
        @document_symbol_stack ||= [dummy_document_symbol]
      end

      # @return [Hash]
      def dummy_document_symbol
        {
          children: []
        }
      end

      # @return [Array<Rucoa::Nodes::SclassNode>]
      def singleton_class_stack
        @singleton_class_stack ||= []
      end
    end
  end
end
