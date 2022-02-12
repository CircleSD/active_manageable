module ActiveManageable
  module Methods
    module Update
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes

        def update(id:, attributes:, options: {})
          initialize_state(attributes: attributes, options: options)

          @target = model_class
          includes(@options[:includes])

          @target = @target.find(id)
          authorize(record: @target)

          @target.update(@attributes)
        end
      end
    end
  end
end
