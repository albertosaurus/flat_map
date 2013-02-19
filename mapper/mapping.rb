module Core
  module FlatMap
    module Mapper::Mapping
      extend ActiveSupport::Concern

      module ClassMethods
        # mapping-modifier options to distinguish options from mappings
        # themselves
        MAPPING_OPTIONS = [:reader, :writer, :format, :multiparam].freeze

        # Define a single or multiple mappings at a time. Usually, a Hash
        # is passed in a form {mapping_name => target_attribute}. All keys
        # that are listed under MAPPING_OPTIONS will be extracted and used
        # as modifiers for new mappings.
        #
        # Also, mapping names may be listed as array that goes before hash.
        # In that case, it's elements are treated as {mapping_name => mapping_name}
        # mapping elements
        #
        # Example:
        #   map :brand, :account_source => :source, :format => :enum
        #   # is equivalent to:
        #   map :brand => :brand, :format => :enum
        #   map :account_source => :source, :format => :enum
        def map(*args)
          mapping_options = args.extract_options!
          mappings = mapping_options.slice!(*MAPPING_OPTIONS)
          mappings_from_array = args.zip(args).flatten
          mappings.merge!(Hash[*mappings_from_array]) unless mappings_from_array.empty?

          define_mappings(mappings, mapping_options)
        end

        # Define a set of +mappings+, passed as {Hash} with +options+ as modifiers.
        # Eventually, adds a mapping factories to list of class mappings. Those
        # factory objects are used to create actual mappings for specific mapper
        # object.
        #
        # @param [Hash] mappings
        # @param [Hash] options
        # @return [Array<Core::FlatMap::Mapping::Factory>] list of mappings
        def define_mappings(mappings, options)
          mappings.each do |name, target_attribute|
            self.mappings << FlatMap::Mapping::Factory.new(name, target_attribute, options)
          end
        end
        private :define_mappings

        # List of class mappings (mapping factories)
        #
        # @return [Array<Core::FlatMap::Mapping::Factory>]
        def mappings
          @mappings ||= []
        end
      end

      # Send passed +params+ +write_from_params+ method of each
      # of the mappings of +self+.
      #
      # Overloaded in {Mountings}
      #
      # @param [Hash] params
      # @return [Hash] params
      def write(params)
        mappings.each do |mapping|
          mapping.write_from_params(params)
        end
        params
      end

      # Send +read_as_params+ method to all mappings associated with
      # self and consolidate results in a single hash
      #
      # @return [Hash] set of read values
      def read
        mappings.inject({}) do |params, mapping|
          params.merge(mapping.read_as_params)
        end
      end

      # Return a list of mappings associated to +self+
      #
      # @return [Core::FlatMap::Mapping]
      def mappings
        @mappings ||= self.class.mappings.map{ |factory| factory.create(self) }
      end
      private :mappings
    end
  end
end
