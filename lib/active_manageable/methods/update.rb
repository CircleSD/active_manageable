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

        @target = @target.find(id)
        authorize(record: @target)

        yield if block_given?

        @target.update(@attributes)
      end
    end
  end
end
