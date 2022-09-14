module ActiveManageable
  module Methods
    module Auxiliary
      module ModelAttributes
        extend ActiveSupport::Concern

        class_methods do
          # Sets the default attribute values to use when building a model object
          # in the new and create methods and these defaults are combined with
          # the attribute values from the methods :attributes argument;
          # accepting either a hash of attribute values or a lambda/proc
          # to execute to return a hash of attribute values;
          # and optional :methods in which to use the attribute values.
          #
          # For example:-
          #   default_attribute_values genre: "pop"
          #   default_attribute_values genre: "pop", released_at: Date.current, methods: :new
          #   default_attribute_values -> { default_attrs }
          #   default_attribute_values -> { default_attrs }, methods: [:new, :create]
          def default_attribute_values(*attributes)
            case attributes.first
            when Hash
              # when the argument contains a hash - extract the methods from the hash
              # attributes value [{:name=>"Dark Side of the Moon", :genre=>"rock", :methods=>:create}]
              methods = attributes.first.delete(:methods)
            when Proc
              # when the argument contains a lambda/proc - extract the methods from the array
              # attributes value [#<Proc:0x0000000110174c90 ... (lambda)>, {:methods=>:create}]
              methods = attributes.extract_options![:methods]
            end
            attrs = attributes.first
            add_method_defaults(key: :attributes, value: attrs, methods: methods)
          end
        end

        private

        # Returns attribute values to use in the new and create methods
        # consisting of a merge of the method attributes argument
        # and class defaults with the method argument taking precedence
        def attribute_values
          @attributes.is_a?(Hash) ? @attributes.reverse_merge(get_default_attribute_values) : @attributes
        end

        # Get the default attribute values for the method
        # from the class attribute that can contain a hash of attribute values
        # or a lambda/proc to execute to return attribute values
        def get_default_attribute_values
          default_attributes = defaults[:attributes] || {}
          attributes = default_attributes[@current_method] || default_attributes[:all] || {}
          attributes = (instance_exec(&attributes) || {}) if attributes.is_a?(Proc)
          attributes.with_indifferent_access
        end
      end
    end
  end
end
