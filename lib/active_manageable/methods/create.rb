module ActiveManageable
  module Methods
    module Create
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::ModelAttributes
      end

      def create(attributes:)
        initialize_state(attributes: attributes)

        @target = build_object_for_create
        authorize(record: @target)

        model_class.transaction do
          yield if block_given?
          create_object
        rescue ActiveRecord::RecordInvalid
          false
        end
      end

      private

      def build_object_for_create
        action_scope.new(attribute_values)
      end

      def create_object
        @target.save!
      end
    end
  end
end
