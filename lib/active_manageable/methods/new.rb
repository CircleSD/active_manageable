module ActiveManageable
  module Methods
    module New
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes
      end

      def new(attributes: {})
        initialize_state(attributes: attributes)

        @target = build_object_for_new
        authorize(record: @target)

        yield if block_given?

        @target
      end

      private

      def build_object_for_new
        action_scope.new(attribute_values)
      end
    end
  end
end
