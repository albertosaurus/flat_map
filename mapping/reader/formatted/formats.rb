module Core
  module FlatMap
    module Mapping::Reader
      module Formatted::Formats
        # Pass +value+ to <tt>Core::I18n::l</tt> method
        def i18n_l(value)
          Core::I18n::l(value) if value
        end

        # Return +name+ attribute of a +value+ which
        # suppose to be an +enum+ record
        def enum(value)
          value.name if value
        end
      end
    end
  end
end
