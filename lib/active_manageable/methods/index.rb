module ActiveManageable
  module Methods
    module Index
      extend ActiveSupport::Concern

      included do
        include ActiveManageable::Methods::Auxiliary::Order
        include ActiveManageable::Methods::Auxiliary::Scopes
        include ActiveManageable::Methods::Auxiliary::Includes
        include ActiveManageable::Methods::Auxiliary::Select
        include ActiveManageable::Methods::Auxiliary::UniqueSearch
      end

      def index(options: {})
        initialize_state(options: options)

        @target = authorization_scope
        authorize(record: model_class)
        search(@options[:search])
        order(@options[:order])
        scopes(@options[:scopes])
        page(@options[:page])
        includes(@options[:includes])
        select(@options[:select])
        distinct(unique_search?)

        @target
      end

      private

      def authorization_scope
        action_scope
      end

      def search(opts)
        @target
      end

      def page(opts)
        @target
      end

      def distinct(value)
        @target = target.distinct(value)
      end
    end
  end
end
