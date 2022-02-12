module ActiveManageable
  module Methods
    module Auxiliary
      module UniqueSearch
        extend ActiveSupport::Concern

        class_methods do
          # Specifies whether to use the distinct method when fetching records in the index method;
          # accepting no argument to always return unique records or a hash with :if or :unless keyword
          # and method name or lambda/proc to execute each time the index method is called.
          #
          # For example:-
          #   has_unique_search
          #   has_unique_search if: :method_name
          #   has_unique_search unless: -> { lambda }
          def has_unique_search(**args)
            self.unique_search = args.present? ? args.assert_valid_keys(:if, :unless) : true
          end
        end

        included do
          class_attribute :unique_search, instance_writer: false, instance_predicate: false

          private

          def unique_search?
            case unique_search
            when nil
              false
            when TrueClass, FalseClass
              unique_search
            when Hash
              evaluate_condition(*unique_search.first)
            end
          end

          def evaluate_condition(condition, method)
            result = case method
            when Symbol
              method(method).call
            when Proc
              instance_exec(&method)
            end
            condition == :if ? result : !result
          end
        end
      end
    end
  end
end
