module Core
  module FlatMap
    module Mapping::Writer
      class Basic
        attr_reader :mapping

        delegate :target, :target_attribute, :to => :mapping

        # Initialize writer by passing +mapping+ to it.
        def initialize(mapping)
          @mapping = mapping
        end

        # Simply calls assignment method of the target, passing
        # +value+ to it
        #
        # @param [Object] value
        # @return [Object] result of assignment
        def write(value)
          target.send("#{target_attribute}=", value)
        end
      end
    end
  end
end
