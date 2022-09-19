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
    # @example returns path from given VSCode URI
    #   source = Rucoa::Source.new(
    #     content: '',
    #     uri: 'file:///path/to/foo.rb'
    #   )
    #   expect(source.path).to eq('/path/to/foo.rb')
    # @example returns name for untitled URI
    #   source = Rucoa::Source.new(
    #     content: '',
    #     uri: 'untitled:Untitled-1'
    #   )
    #   expect(source.path).to eq('Untitled-1')
    def path
      return unless @uri

      return @uri.split(':', 2).last if untitled?

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
      @uri&.start_with?('untitled:')
    end

    private

    # @return [Rucoa::ParseResult]
    def parse_result
      return @parse_result if instance_variable_defined?(:@parse_result)

      @parse_result = Parser.call(
        path: path,
        text: @content
      )
    end

    # @return [Array<Rucoa::Nodes::Base>]
    def root_and_descendant_nodes
      return [] unless root_node

      [root_node, *root_node.descendants]
    end
  end
end
