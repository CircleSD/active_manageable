module ActiveManageable
  module Methods
    module Create
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes
      end

      def create(attributes:)
        initialize_state(attributes: attributes)

        @target = action_scope.new(attribute_values)
        authorize(record: @target)

        yield if block_given?

        @target.save
      end
    end
  end
end
