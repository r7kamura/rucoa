# frozen_string_literal: true

module Rucoa
  module Rbs
    class ModuleDefinitionMapper
      class << self
        # @param declaration [RBS::AST::Declarations::Module]
        # @return [Rucoa::Definitions::ModuleDefinition]
        def call(declaration:)
          new(declaration: declaration).call
        end
      end

      # @param declaration [RBS::AST::Declarations::Module]
      def initialize(declaration:)
        @declaration = declaration
      end

      # @return [Rucoa::Definitions::ModuleDefinition]
      def call
        Definitions::ModuleDefinition.new(
          description: description,
          extended_module_qualified_names: extended_module_qualified_names,
          included_module_qualified_names: included_module_qualified_names,
          location: location,
          prepended_module_qualified_names: prepended_module_qualified_names,
          qualified_name: qualified_name
        )
      end

      private

      # @return [String, nil]
      def description
        @declaration.comment&.string&.sub(/\A\s*<!--.*-->\s*/m, '')
      end

      # @return [Array<String>]
      def extended_module_qualified_names
        module_qualified_names_for(::RBS::AST::Members::Extend)
      end

      # @return [Array<String>]
      def included_module_qualified_names
        module_qualified_names_for(::RBS::AST::Members::Include)
      end

      # @return [Rucoa::Location]
      def location
        Location.from_rbs_location(@declaration.location)
      end

      def module_qualified_names_for(member_class)
        @declaration.members.filter_map do |member|
          case member
          when member_class
            member.name.to_s.delete_prefix('::')
          end
        end
      end

      # @return [Array<String>]
      def prepended_module_qualified_names
        module_qualified_names_for(::RBS::AST::Members::Prepend)
      end

      # @return [String]
      def qualified_name
        @declaration.name.to_s.delete_prefix('::')
      end
    end
  end
end
