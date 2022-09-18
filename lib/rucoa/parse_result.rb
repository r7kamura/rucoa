# frozen_string_literal: true

module Rucoa
  class ParseResult
    # @return [Array<Parser::Source::Comment>, nil]
    attr_reader :associations

    # @return [Rucoa::Nodes::Base, nil]
    attr_reader :root_node

    # @param associations [Array<Parser::Source::Comment>, nil]
    # @param failed [Boolean]
    # @param root_node [Rucoa::Nodes::Base, nil]
    def initialize(
      associations: nil,
      failed: false,
      root_node: nil
    )
      @associations = associations
      @failed = failed
      @root_node = root_node
    end

    # @return [Boolean]
    def failed?
      @failed
    end
  end
end
