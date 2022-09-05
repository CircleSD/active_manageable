module ActiveManageable
  module Methods
    module New
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes

        def new(attributes: {})
          initialize_state(attributes: attributes)

          @target = action_scope.new(attribute_values)
          authorize(record: @target)

          @target
        end
      end
    end
  end
end
