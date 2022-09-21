# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDefinitionHandler < Base
      def call
        respond(location)
      end

      private

      # @return [Hash, nil]
      def location
        return unless reponsible?

        {
          range: location_range.to_vscode_range,
          uri: location_uri
        }
      end

      # @return [Boolean]
      def reponsible?
        configuration.enables_definition? &&
          !location_uri.nil? &&
          !location_source.nil?
      end

      # @return [Rucoa::Range]
      def location_range
        return Range.from_parser_range(location_node.location.expression) if location_node

        Position.new.to_range
      end

      # @return [String, nil]
      def location_uri
        return unless definition

        if definition.source_path.start_with?('Untitled-')
          "untitled:#{definition.source_path}"
        else
          "file://#{definition.source_path}"
        end
      end

      # @return [Rucoa::Nodes::Base, nil]
      def location_node
        @location_node ||=
          case definition
          when Definitions::ClassDefinition
            find_class_node
          when Definitions::ModuleDefinition
            find_module_node
          when Definitions::MethodDefinition
            find_method_node
          end
      end

      # @return [Rucoa::Source, nil]
      def location_source
        source_store.get(location_uri)
      end

      # @return [Rucoa::Position]
      def position
        Position.from_vscode_position(
          request.dig('params', 'position')
        )
      end

      # @return [String]
      def uri
        request.dig('params', 'textDocument', 'uri')
      end

      # @return [Rucoa::Source, nil]
      def source
        source_store.get(uri)
      end

      # @return [Rucoa::Nodes::Base]
      def node
        source&.node_at(position)
      end

      # @return [Rucoa::Definitions::Base, nil]
      def definition
        @definition ||= NodeInspector.new(
          definition_store: definition_store,
          node: node
        ).definitions.first
      end

      # @return [Rucoa::Nodes::ClassNode, nil]
      def find_class_node
        find_by_fully_qualified_name(
          fully_qualified_name: definition.fully_qualified_name,
          klass: Nodes::ClassNode
        ) || find_by_name(
          klass: Nodes::ClassNode,
          name: definition.name
        )
      end

      # @return [Rucoa::Nodes::ModuleNode, nil]
      def find_module_node
        find_by_fully_qualified_name(
          fully_qualified_name: definition.fully_qualified_name,
          klass: Nodes::ModuleNode
        ) || find_by_name(
          klass: Nodes::ModuleNode,
          name: definition.name
        )
      end

      # @return [Rucoa::Nodes::MethodNode, nil]
      def find_method_node
        location_root_or_descendant_nodes.reverse.find do |node|
          node.is_a?(Nodes::DefNode) &&
            node.name == definition.method_name &&
            node.namespace == definition.namespace
        end
      end

      # @param fully_qualified_name [String]
      # @param klass [Class]
      # @return [Rucoa::Nodes::Base, nil]
      def find_by_fully_qualified_name(
        fully_qualified_name:,
        klass:
      )
        location_root_or_descendant_nodes.reverse.find do |node|
          node.is_a?(klass) &&
            node.fully_qualified_name == fully_qualified_name
        end
      end

      # @param name [String]
      # @param klass [Class]
      # @return [Rucoa::Nodes::Base, nil]
      def find_by_name(
        klass:,
        name:
      )
        location_root_or_descendant_nodes.reverse.find do |node|
          node.is_a?(klass) &&
            node.name == name
        end
      end

      # @return [Array<Rucoa::Nodes::Base>]
      def location_root_or_descendant_nodes
        @location_root_or_descendant_nodes ||= [
          location_source.root_node,
          *location_source.root_node.descendants
        ]
      end
    end
  end
end
