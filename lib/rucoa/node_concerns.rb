# frozen_string_literal: true

module Rucoa
  module NodeConcerns
    autoload :Body, 'rucoa/node_concerns/body'
    autoload :Modifier, 'rucoa/node_concerns/modifier'
    autoload :QualifiedName, 'rucoa/node_concerns/qualified_name'
    autoload :Rescue, 'rucoa/node_concerns/rescue'
    autoload :Variable, 'rucoa/node_concerns/variable'
  end
end
