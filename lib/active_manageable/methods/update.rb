module ActiveManageable
  module Methods
    module Update
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes
      end

      def update(id:, attributes:, options: {})
        initialize_state(attributes: attributes, options: options)

        @target = action_scope
        includes(@options[:includes])

        @target = find_object_for_update(id: id)
        authorize(record: @target)

        assign_attributes_for_update

        yield if block_given?

        update_object
      end

      private

      def find_object_for_update(id:)
        @target.find(id)
      end

      def assign_attributes_for_update
        @target.assign_attributes(@attributes)
      end

      def update_object
        @target.save
      end
    end
  end
end
