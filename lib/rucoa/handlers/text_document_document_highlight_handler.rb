# frozen_string_literal: true

module Rucoa
  module Handlers
    class TextDocumentDocumentHighlightHandler < Base
      include HandlerConcerns::TextDocumentPositionParameters
      include HandlerConcerns::TextDocumentUriParameters

      DOCUMENT_HIGHLIGHT_KIND_READ = 2
      DOCUMENT_HIGHLIGHT_KIND_TEXT = 1
      DOCUMENT_HIGHLIGHT_KIND_WRITE = 3

      # @return [void]
      def call
        respond(document_highlights)
      end

      private

      # @return [Array<Hash>]
      def document_highlights
        parser_ranges.map do |parser_range|
          {
            'kind' => DOCUMENT_HIGHLIGHT_KIND_TEXT,
            'range' => Range.from_parser_range(parser_range).to_vscode_range
          }
        end
      end

      # @return [Array<Parser::Source::Range>]
      def parser_ranges
        return [] unless reponsible?

        NodeToRangesMappers::AnyMapper.call(node)
      end

      # @return [Boolean]
      def reponsible?
        configuration.enables_highlight?
      end

      module NodeToRangesMappers
        class Base
          class << self
            # @param node [Rucoa::Nodes::Base]
            # @return [Array<Parser::Source::Range>]
            def call(node)
              new(node).call
            end
          end

          # @param node [Rucoa::Nodes::Base]
          def initialize(node)
            @node = node
          end

          # @return [Array<Parser::Source::Range>]
          def call
            raise ::NotImplementedError
          end
        end

        class AnyMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            case @node
            when Nodes::BeginNode, Nodes::BlockNode
              BeginMapper.call(@node)
            when Nodes::CaseNode
              CaseMapper.call(@node)
            when Nodes::ClassNode, Nodes::ModuleNode
              ModuleMapper.call(@node)
            when Nodes::DefNode
              DefMapper.call(@node)
            when Nodes::EnsureNode, Nodes::ResbodyNode, Nodes::RescueNode, Nodes::WhenNode
              AnyMapper.call(@node.parent)
            when Nodes::ForNode
              ForMapper.call(@node)
            when Nodes::IfNode
              IfMapper.call(@node)
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
          # @return [Array<Parser::Source::Range>]
          def call
            [
              range_begin,
              *ranges_resbody,
              range_else,
              range_ensure,
              range_end
            ].compact
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

          # @return [Array<Parser::Source::Range>]
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
          # @return [Array<Parser::Source::Range>]
          def call
            [
              @node.location.keyword,
              *ranges_when,
              @node.location.else,
              @node.location.end
            ].compact
          end

          private

          # @return [Array<Parser::Source::Range>]
          def ranges_when
            @node.whens.map do |when_node|
              when_node.location.keyword
            end
          end
        end

        class IfMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            return AnyMapper.call(@node.parent) if @node.elsif?

            [
              @node.location.keyword,
              *ranges_elsif,
              @node.location.else,
              @node.location.end
            ].compact
          end

          private

          # @return [Array<Parser::Source::Range>]
          def ranges_elsif
            return [] unless @node.elsif

            ElsifMapper.call(@node.elsif)
          end
        end

        class ElsifMapper < IfMapper
          # @return [Array<Parser::Source::Range>]
          def call
            [
              *ranges_elsif,
              @node.location.else
            ].compact
          end
        end

        class ForMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            [
              @node.location.keyword,
              @node.location.in,
              @node.location.end
            ].compact
          end
        end

        class ModuleMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            [
              @node.location.keyword,
              @node.location.end
            ]
          end
        end

        class SendMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            return [] unless @node.block

            BeginMapper.call(@node.block)
          end
        end

        class WhenMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            CaseMapper.call(@node.parent)
          end
        end

        class WhileMapper < Base
          # @return [Array<Parser::Source::Range>]
          def call
            [
              @node.location.keyword,
              @node.location.end
            ]
          end
        end
      end
    end
  end
end
