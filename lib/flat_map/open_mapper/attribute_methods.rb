module FlatMap
  # This module allows mappers to return and assign values via method calls
  # which names correspond to names of mappings defined within the mapper.
  #
  # This methods are defined within anonymous module that will extend
  # mapper on first usage of this methods.
  #
  # NOTE: :to_ary method is called internally by Ruby 1.9.3 when we call
  # something like [mapper].flatten. And we DO want default behavior
  # for handling this missing method.
  module OpenMapper::AttributeMethods
    # Lazily define reader and writer methods for all mappings available
    # to the mapper, and extend +self+ with it.
    def method_missing(name, *args, &block)
      if name == :to_ary ||
          @attribute_methods_defined ||
          self.class.protected_instance_methods.include?(name)
        return super
      end

      mappings    = all_mappings
      valid_names = mappings.map do |mapping|
        full_name = mapping.full_name
        [full_name, "#{full_name}=".to_sym]
      end
      valid_names.flatten!

      return super unless valid_names.include?(name)

      extend attribute_methods(mappings)
      @attribute_methods_defined = true
      send(name, *args, &block)
    end

    # Define anonymous module with reader and writer methods for
    # all the +mappings+ being passed.
    #
    # @param [Array<FlatMap::Mapping>] mappings list of mappings
    # @return [Module] module with method definitions
    def attribute_methods(mappings)
      Module.new do
        mappings.each do |mapping|
          full_name = mapping.full_name

          define_method(full_name){ |*args| mapping.read(*args) }

          define_method("#{full_name}=") do |value|
            mapping.write(value)
          end
        end
      end
    end
    private :attribute_methods
  end
end
