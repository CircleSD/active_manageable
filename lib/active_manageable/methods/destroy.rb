module ActiveManageable
  module Methods
    module Destroy
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes
      end

      def destroy(id:, options: {})
        initialize_state(options: options)

        @target = action_scope
        includes(@options[:includes])

        @target = find_object_for_destroy(id: id)
        authorize(record: @target)

        model_class.transaction do
          yield if block_given?
          destroy_object
        rescue ActiveRecord::RecordNotDestroyed
          false
        end
      end

      private

      def find_object_for_destroy(id:)
        @target.find(id)
      end

      def destroy_object
        @target.destroy!
      end
    end
  end
end
