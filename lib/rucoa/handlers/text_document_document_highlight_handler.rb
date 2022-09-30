# frozen_string_literal: true

require 'set'

module Rucoa
  module Handlers
    class TextDocumentDocumentHighlightHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters
      include HandlerConcerns::TextDocumentUriParameters

      # @return [void]
      def call
        respond(document_highlights)
      end

      private

      # @return [Array]
      def document_highlights
        return [] unless reponsible?

        NodeToHighlightsMappers::AnyMapper.call(node).map(&:to_vscode_highlight)
      end

      # @return [Boolean]
      def reponsible?
        configuration.enables_highlight?
      end

      module Highlights
        class Base
          # @param parser_range [Parser::Source::Range]
          def initialize(parser_range:)
            @parser_range = parser_range
          end

          private

          # @return [Hash]
          def vscode_range
            Range.from_parser_range(@parser_range).to_vscode_range
          end
        end

        class TextHighlight < Base
          # @return [Hash]
          def to_vscode_highlight
            {
              kind: 1,
              range: vscode_range
            }
          end
        end

        class ReadHighlight < Base
          # @return [Hash]
          def to_vscode_highlight
            {
              kind: 2,
              range: vscode_range
            }
          end
        end

        class WriteHighlight < Base
          # @return [Hash]
          def to_vscode_highlight
            {
              kind: 3,
              range: vscode_range
            }
          end
        end
      end

      module NodeToHighlightsMappers
        class Base
          class << self
            # @param node [Rucoa::Nodes::Base]
            # @return [Array]
            def call(node)
              new(node).call
            end
          end

          # @param node [Rucoa::Nodes::Base]
          def initialize(node)
            @node = node
          end

          # @return [Array]
          def call
            raise ::NotImplementedError
          end
        end

        class AnyMapper < Base
          # @return [Array]
          def call
            case @node
            when Nodes::BeginNode, Nodes::BlockNode
              BeginMapper.call(@node)
            when Nodes::CaseNode
              CaseMapper.call(@node)
            when Nodes::ClassNode, Nodes::ModuleNode
              ModuleMapper.call(@node)
            when Nodes::CvarNode, Nodes::CvasgnNode
              ClassVariableMapper.call(@node)
            when Nodes::DefNode
              DefMapper.call(@node)
            when Nodes::EnsureNode, Nodes::ResbodyNode, Nodes::RescueNode, Nodes::WhenNode
              AnyMapper.call(@node.parent)
            when Nodes::ForNode
              ForMapper.call(@node)
            when Nodes::GvarNode, Nodes::GvasgnNode
              GlobalVariableMapper.call(@node)
            when Nodes::IfNode
              IfMapper.call(@node)
            when Nodes::IvarNode, Nodes::IvasgnNode
              InstanceVariableMapper.call(@node)
            when Nodes::ArgNode, Nodes::LvarNode, Nodes::LvasgnNode
              LocalVariableMapper.call(@node)
            when Nodes::SendNode
              SendMapper.call(@node)
            when Nodes::UntilNode, Nodes::WhileNode
              WhileMapper.call(@node)
            else
              []
            end
          end
        end

        class BeginMapper < Base
          # @return [Array]
          def call
            [
              range_begin,
              *ranges_resbody,
              range_else,
              range_ensure,
              range_end
            ].compact.map do |parser_range|
              Highlights::TextHighlight.new(parser_range: parser_range)
            end
          end

          private

          # @return [Parser::Source::Range]
          def range_begin
            @node.location.begin
          end

          # @return [Parser::Source::Range, nil]
          def range_else
            return unless rescue_node

            rescue_node.location.else
          end

          # @return [Parser::Source::Range]
          def range_end
            @node.location.end
          end

          # @return [Parser::Source::Range]
          def range_ensure
            return unless @node.ensure

            @node.ensure.location.keyword
          end

          # @return [Array]
          def ranges_resbody
            return [] unless rescue_node

            rescue_node.resbodies.map do |resbody|
              resbody.location.keyword
            end
          end

          # @return [Rucoa::Nodes::RescueNode, nil]
          def rescue_node
            @rescue_node ||= @node.rescue || @node.ensure&.rescue
          end
        end

        class DefMapper < BeginMapper
          private

          # @return [Parser::Source::Range]
          def range_begin
            @node.location.keyword
          end
        end

        class CaseMapper < Base
          # @return [Array]
          def call
            [
              @node.location.keyword,
              *ranges_when,
              @node.location.else,
              @node.location.end
            ].compact.map do |parser_range|
              Highlights::TextHighlight.new(parser_range: parser_range)
            end
          end

          private

          # @return [Array]
          def ranges_when
            @node.whens.map do |when_node|
              when_node.location.keyword
            end
          end
        end

        class IfMapper < Base
          # @return [Array]
          def call
            return AnyMapper.call(@node.parent) if @node.elsif?
            return [] if @node.modifier?

            [
              highlight_keyword,
              *highlights_elsif,
              highlight_else,
              highlight_end
            ].compact
          end

          private

          def highlight_else
            Highlights::TextHighlight.new(parser_range: @node.location.else) if @node.location.else
          end

          def highlight_end
            Highlights::TextHighlight.new(parser_range: @node.location.end)
          end

          def highlight_keyword
            Highlights::TextHighlight.new(parser_range: @node.location.keyword)
          end

          # @return [Array]
          def highlights_elsif
            return [] unless @node.elsif

            ElsifMapper.call(@node.elsif)
          end
        end

        class ElsifMapper < IfMapper
          # @return [Array]
          def call
            [
              *highlights_elsif,
              highlight_else
            ].compact
          end
        end

        class ForMapper < Base
          # @return [Array]
          def call
            [
              @node.location.keyword,
              @node.location.in,
              @node.location.end
            ].compact.map do |parser_range|
              Highlights::TextHighlight.new(parser_range: parser_range)
            end
          end
        end

        class GlobalVariableMapper < Base
          # @return [Array]
          def call
            nodes.map do |node|
              case node
              when Nodes::GvarNode
                Highlights::ReadHighlight
              when Nodes::GvasgnNode
                Highlights::WriteHighlight
              end.new(parser_range: node.location.name)
            end
          end

          private

          # @return [Rucoa::Nodes::Base, nil]
          def global_variable_scopable_node
            @node.ancestors.last
          end

          # @return [Enumerable<Rucoa::Nodes::Base>]
          def nodes
            return [] unless global_variable_scopable_node

            global_variable_scopable_node.each_descendant_node(:gvar, :gvasgn).select do |node|
              node.name == @node.name
            end
          end
        end

        class InstanceVariableMapper < Base
          # @return [Array]
          def call
            nodes.map do |node|
              case node
              when Nodes::IvarNode
                Highlights::ReadHighlight
              when Nodes::IvasgnNode
                Highlights::WriteHighlight
              end.new(parser_range: node.location.name)
            end
          end

          private

          # @return [Rucoa::Nodes::Base, nil]
          def instance_variable_scopable_node
            @instance_variable_scopable_node ||= @node.each_ancestor(:class, :module).first
          end

          # @todo Stop descendant searching if scope boundary node is found (e.g. class, def, etc.).
          # @return [Enumerable<Rucoa::Nodes::Base>]
          def nodes
            return [] unless instance_variable_scopable_node

            instance_variable_scopable_node.each_descendant_node(:ivar, :ivasgn).select do |node|
              node.name == @node.name
            end
          end
        end

        class ClassVariableMapper < Base
          # @return [Array]
          def call
            nodes.map do |node|
              case node
              when Nodes::CvarNode
                Highlights::ReadHighlight
              when Nodes::CvasgnNode
                Highlights::WriteHighlight
              end.new(parser_range: node.location.name)
            end
          end

          private

          # @return [Rucoa::Nodes::Base, nil]
          def instance_variable_scopable_node
            @node.each_ancestor(:class, :module).first
          end

          # @return [Enumerable<Rucoa::Nodes::Base>]
          def nodes
            return [] unless instance_variable_scopable_node

            instance_variable_scopable_node.each_descendant_node(:cvar, :cvasgn).select do |node|
              node.name == @node.name
            end
          end
        end

        class LocalVariableMapper < Base
          SCOPE_BOUNDARY_NODE_TYPES = ::Set[
            :class,
            :def,
            :defs,
            :module,
          ]

          # @return [Array]
          def call
            nodes.map do |node|
              case node
              when Nodes::LvarNode
                Highlights::ReadHighlight
              when Nodes::ArgNode, Nodes::LvasgnNode
                Highlights::WriteHighlight
              end.new(parser_range: node.location.name)
            end
          end

          private

          # @return [Rucoa::Nodes::ArgNode, Rucoa::Nodes::LvasgnNode, nil]
          def assignment_node
            @assignment_node ||=
              case @node
              when Nodes::ArgNode, Nodes::LvasgnNode
                @node
              when Nodes::LvarNode
                (
                  [@node] + @node.ancestors.take_while do |node|
                    !SCOPE_BOUNDARY_NODE_TYPES.include?(node.type)
                  end
                ).find do |node|
                  case node
                  when Nodes::ArgNode, Nodes::LvasgnNode
                    node.name == @node.name
                  when Nodes::BlockNode, Nodes::DefNode
                    target = node.arguments.find do |argument|
                      argument.name == @node.name
                    end
                    break target if target
                  else
                    target = node.previous_sibling_nodes.reverse.find do |sibling_node|
                      lvasgn_node = [
                        sibling_node,
                        *sibling_node.descendant_nodes
                      ].reverse.find do |sibling_or_sibling_descendant|
                        case sibling_or_sibling_descendant
                        when Nodes::LvasgnNode
                          break sibling_or_sibling_descendant if sibling_or_sibling_descendant.name == @node.name
                        end
                      end
                      break lvasgn_node if lvasgn_node
                    end
                    break target if target
                  end
                end || @node.each_ancestor(:def, :defs).first&.then do |node|
                  break node.arguments.find do |argument|
                    argument.name == @node.name
                  end
                end
              end
          end

          # @return [Enumerable<Rucoa::Nodes::ArgNode, Rucoa::Nodes::LvarNode, Rucoa::Nodes::LvasgnNode>]
          def nodes
            [
              assignment_node,
              *reference_nodes
            ].compact
          end

          # @return [Enumerable<Rucoa::Nodes::LvarNode>]
          def reference_nodes
            return [] unless assignment_node

            case assignment_node
            when Nodes::ArgNode
              assignment_node.each_ancestor(:block, :def, :defs).first.body_children
            when Nodes::LvasgnNode
              (
                [assignment_node] + assignment_node.ancestors.take_while do |node|
                  !SCOPE_BOUNDARY_NODE_TYPES.include?(node.type)
                end
              ).flat_map(&:next_sibling_nodes)
            end.flat_map do |node|
              [
                node,
                *node.descendant_nodes
              ]
            end.take_while do |node| # FIXME: flat_map and take_while are not correct solution for shadowing.
              case node
              when Nodes::ArgNode, Nodes::LvasgnNode
                node.equal?(assignment_node) || node.name != assignment_node.name
              else
                true
              end
            end.select do |node|
              case node
              when Nodes::LvarNode
                node.name == @node.name
              end
            end
          end

          class UnshadowedNodeVisitor
            def initialize(
              node:,
              &block
            )
              @block = block
              @node = node
            end
          end
        end

        class ModuleMapper < Base
          # @return [Array]
          def call
            [
              @node.location.keyword,
              @node.location.end
            ].map do |parser_range|
              Highlights::TextHighlight.new(parser_range: parser_range)
            end
          end
        end

        class SendMapper < Base
          # @return [Array]
          def call
            return [] unless @node.block

            BeginMapper.call(@node.block)
          end
        end

        class WhenMapper < Base
          # @return [Array]
          def call
            CaseMapper.call(@node.parent)
          end
        end

        class WhileMapper < Base
          # @return [Array]
          def call
            return [] if @node.modifier?

            [
              @node.location.keyword,
              @node.location.end
            ].map do |parser_range|
              Highlights::TextHighlight.new(parser_range: parser_range)
            end
          end
        end
      end
    end
  end
end
