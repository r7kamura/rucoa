# frozen_string_literal: true

module Rucoa
  module Nodes
    class BeginNode < Base
      include NodeConcerns::Body
      include NodeConcerns::Rescue
    end
  end
end
