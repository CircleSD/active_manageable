module ActiveManageable
  module Methods
    module Show
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes
        include ActiveManageable::Methods::Auxiliary::Select

        def show(id:, options: {})
          initialize_state(options: options)

          @target = model_class
          includes(@options[:includes])
          select(@options[:select])

          @target = @target.find(id)
          authorize(record: @target)

          @target
        end
      end
    end
  end
end
