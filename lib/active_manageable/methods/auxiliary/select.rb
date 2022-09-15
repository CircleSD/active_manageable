module ActiveManageable
  module Methods
    module Auxiliary
      module Select
        extend ActiveSupport::Concern

        class_methods do
          # Sets the default attributes to return in the SELECT statement used
          # when fetching records in the index, show and edit methods
          # if the methods :options argument does not contain a :select key;
          # accepting either an array of attribute names or a lambda/proc
          # to execute to return an array of attribute names;
          # and optional :methods in which to use the attributes.
          #
          # For example:-
          #   default_select :name
          #   default_select :id, :name, methods: :show
          #   default_select -> { select_attributes }
          #   default_select -> { select_attributes }, methods: [:index, :edit]
          def default_select(*attributes)
            options = attributes.extract_options!.dup
            attrs = attributes.first.is_a?(Proc) ? attributes.first : attributes
            add_method_defaults(key: :select, value: attrs, methods: options[:methods])
          end
        end

        # Returns the default select attributes for the method
        # from the class attribute that can contain an array of attribute names
        # or a lambdas/procs to execute to return an array of attribute names
        def default_select(method: @current_method)
          default_selects = defaults[:select] || {}
          attributes = default_selects[method.try(:to_sym)] || default_selects[:all] || []
          attributes.is_a?(Proc) ? instance_exec(&attributes) : attributes
        end

        private

        def select(attributes)
          @target = @target.select(attributes || default_select)
        end
      end
    end
  end
end
