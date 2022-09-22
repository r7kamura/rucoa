# frozen_string_literal: true

module Rucoa
  module Definitions
    class ClassDefinition < ModuleDefinition
      # @return [Arra<String>, nil]
      attr_reader :module_nesting

      # @return [String, nil]
      attr_reader :super_class_chained_name

      # @return [String, nil]
      attr_accessor :super_class_fully_qualified_name

      # @param module_nesting [Array<String>, nil]
      # @param super_class_chained_name [String, nil]
      # @param super_class_fully_qualified_name [String, nil]
      def initialize(
        module_nesting: nil,
        super_class_chained_name: nil,
        super_class_fully_qualified_name: nil,
        **keyword_arguments
      )
        super(**keyword_arguments)
        @module_nesting = module_nesting
        @super_class_chained_name = super_class_chained_name
        @super_class_fully_qualified_name = super_class_fully_qualified_name
      end

      # @return [Boolean]
      # @example returns false on not-resolved case
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Baz < Bar
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/baz.rb',
      #   ).definitions[1]
      #   expect(definition).not_to be_super_class_resolved
      # @example returns true on resolved case
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Baz < Bar
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/baz.rb',
      #   ).definitions[1]
      #   definition.super_class_fully_qualified_name = 'Foo::Bar'
      #   expect(definition).to be_super_class_resolved
      def super_class_resolved?
        !@super_class_fully_qualified_name.nil?
      end

      # @return [Array<String>]
      # @example returns candidates of super class fully qualified name
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Baz < Bar
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/baz.rb',
      #   ).definitions[1]
      #   expect(definition.super_class_candidates).to eq(
      #     %w[Foo::Bar Bar]
      #   )
      # @example returns only correct answer if it's already resolved
      #   definition = Rucoa::Source.new(
      #     content: <<~RUBY,
      #       module Foo
      #         class Baz < Bar
      #         end
      #       end
      #     RUBY
      #     uri: 'file:///path/to/foo/baz.rb',
      #   ).definitions[1]
      #   definition.super_class_fully_qualified_name = 'Foo::Bar'
      #   expect(definition.super_class_candidates).to eq(
      #     %w[Foo::Bar]
      #   )
      def super_class_candidates
        return [super_class_fully_qualified_name] if super_class_resolved?

        module_nesting.map do |chained_name|
          [
            chained_name,
            super_class_chained_name
          ].join('::')
        end + [super_class_chained_name]
      end
    end
  end
end
