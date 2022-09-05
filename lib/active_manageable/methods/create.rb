module ActiveManageable
  module Methods
    module Create
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes

        def create(attributes:)
          initialize_state(attributes: attributes)

          @target = action_scope.new(attribute_values)
          authorize(record: @target)

          @target.save
        end
      end
    end
  end
end
