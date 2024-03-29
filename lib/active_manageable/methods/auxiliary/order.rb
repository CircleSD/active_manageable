module ActiveManageable
  module Methods
    module Auxiliary
      module Order
        extend ActiveSupport::Concern

        class_methods do
          # Sets the default order to use when fetching records in the index method
          # if the index :options argument does not contain an :order key;
          # accepting attributes in the same formats as the ActiveRecord order method
          # or a lambda/proc to execute to return attributes in the recognised formats.
          #
          # For example:-
          #   default_order :name
          #   default_order "name DESC"
          #   default_order -> { order_attributes }
          def default_order(*attributes)
            defaults[:order] = attributes.first.is_a?(Proc) ? attributes.first : attributes
          end
        end

        # Returns the default order attributes from the class attribute
        # that can contain an array of attribute names or name & direction strings
        # or a lambda/proc to execute to return an array of attribute names
        def default_order
          defaults[:order].is_a?(Proc) ? instance_exec(&defaults[:order]) : defaults[:order]
        end

        private

        def order(attributes)
          @target = @target.order(order_attributes(attributes))
        end

        def order_attributes(attributes)
          attributes || default_order
        end
      end
    end
  end
end
