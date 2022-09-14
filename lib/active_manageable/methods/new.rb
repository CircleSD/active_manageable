module ActiveManageable
  module Methods
    module New
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes
      end

      def new(attributes: {})
        initialize_state(attributes: attributes)

        @target = action_scope.new(attribute_values)
        authorize(record: @target)

        yield if block_given?

        @target
      end
    end
  end
end
