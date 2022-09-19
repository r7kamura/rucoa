# frozen_string_literal: true

require 'uri'

module Rucoa
  class Source
    # @return [String]
    attr_reader :content

    # @return [String]
    attr_reader :uri

    # @param content [String]
    # @param uri [String]
    def initialize(content:, uri:)
      @content = content
      @uri = uri
    end

    # @return [Array<Rucoa::Definition::Base>]
    # @example returns definitions from given source
    #   content = <<~RUBY
    #     class Foo
    #       def bar
    #       end
    #     end
    #   RUBY
    #   source = Rucoa::Source.new(
    #     content: content,
    #     uri: 'file:///path/to/foo.rb'
    #   )
    #   expect(source.definitions).to match(
    #     [
    #       a_kind_of(Rucoa::Definitions::ClassDefinition),
    #       a_kind_of(Rucoa::Definitions::MethodDefinition)
    #     ]
    #   )
    def definitions
      @definitions ||=
        if parse_result.failed?
          []
        else
          Yard::DefinitionsLoader.call(
            associations: parse_result.associations,
            root_node: parse_result.root_node
          )
        end
    end

    # @return [String, nil]
    # @example returns path for file URI
    #   source = Rucoa::Source.new(
    #     content: '',
    #     uri: 'file:///path/to/foo.rb'
    #   )
    #   expect(source.name).to eq('/path/to/foo.rb')
    # @example returns opaque for untitled URI
    #   source = Rucoa::Source.new(
    #     content: '',
    #     uri: 'untitled:Untitled-1'
    #   )
    #   expect(source.name).to eq('Untitled-1')
    def name
      if untitled?
        uri_object.opaque
      else
        uri_object.path
      end
    end

    # @param position [Rucoa::Position]
    # @return [Rucoa::Nodes::Base, nil]
    def node_at(position)
      root_and_descendant_nodes.reverse.find do |node|
        node.include_position?(position)
      end
    end

    # @return [Rucoa::Nodes::Base, nil]
    def root_node
      parse_result.root_node
    end

    # @return [Boolean]
    def failed_to_parse?
      parse_result.failed?
    end

    # @return [Boolean]
    def untitled?
      uri_object.scheme == 'untitled'
    end

    private

    # @return [Rucoa::ParseResult]
    def parse_result
      return @parse_result if instance_variable_defined?(:@parse_result)

      @parse_result = Parser.call(
        path: name,
        text: @content
      )
    end

    # @return [Array<Rucoa::Nodes::Base>]
    def root_and_descendant_nodes
      return [] unless root_node

      [root_node, *root_node.descendants]
    end

    # @return [URI]
    def uri_object
      @uri_object ||= ::URI.parse(@uri)
    end
  end
end
