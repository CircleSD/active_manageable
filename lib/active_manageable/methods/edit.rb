module ActiveManageable
  module Methods
    module Edit
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Includes
        include ActiveManageable::Methods::Auxiliary::Select

        def edit(id:, options: {})
          initialize_state(options: options)

          @target = action_scope
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
