# frozen_string_literal: true

module Rucoa
  class Source
    # @return [String]
    attr_reader :content

    # @return [String]
    attr_reader :uri

    # @param content [String]
    # @param uri [String, nil]
    def initialize(content:, uri: nil)
      @content = content
      @uri = uri
    end

    # @todo
    # @return [Array<Rucoa::Definition::Base>]
    def definitions
      @definitions ||= []
    end

    # @return [String, nil]
    def path
      return unless @uri

      path = ::URI.parse(@uri).path
      return unless path

      ::CGI.unescape(path)
    end

    # @param position [Rucoa::Position]
    # @return [Rucoa::Nodes::Base, nil]
    def node_at(position)
      root_and_descendant_nodes.reverse.find do |node|
        node.include_position?(position)
      end
    rescue ::Parser::SyntaxError
      nil
    end

    # @return [Rucoa::Nodes::Base, nil]
    def root_node
      @root_node ||= Parser.call(@content)
    rescue ::Parser::SyntaxError
      nil
    end

    private

    # @return [Array<Rucoa::Nodes::Base>]
    def root_and_descendant_nodes
      return [] unless root_node

      [root_node, *root_node.descendants]
    end
  end
end
