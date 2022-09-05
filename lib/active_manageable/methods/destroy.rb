module ActiveManageable
  module Methods
    module Destroy
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes

        def destroy(id:, options: {})
          initialize_state(options: options)

          @target = action_scope
          includes(@options[:includes])

          @target = @target.find(id)
          authorize(record: @target)

          @target.destroy
        end
      end
    end
  end
end
