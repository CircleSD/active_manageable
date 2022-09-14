module ActiveManageable
  module Methods
    module Edit
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes
        include ActiveManageable::Methods::Auxiliary::Select
      end

      def edit(id:, options: {})
        initialize_state(options: options)

        @target = action_scope
        includes(@options[:includes])
        select(@options[:select])

        yield if block_given?

        @target = find_object_for_edit(id: id)
        authorize(record: @target)

        @target
      end

      private

      def find_object_for_edit(id:)
        @target.find(id)
      end
    end
  end
end
