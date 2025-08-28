module ActiveManageable
  module Methods
    module Auxiliary
      module Scopes
        extend ActiveSupport::Concern

        class_methods do
          # Sets the default scope(s) to use when fetching records in the index method
          # if the index :options argument does not contain a :scopes key;
          # accepting a scope name, a hash containing scope name and argument, or an array of names/hashes;
          # also accepting a lambda/proc to execute to return a scope name or hash or array.
          #
          # For example:-
          #   default_scopes :electronic
          #   default_scopes {released_in_year: "1980"}
          #   default_scopes :rock, :electronic, {released_in_year: "1980"}
          #   default_scopes -> { index_scopes }
          def default_scopes(*args)
            defaults[:scopes] = args.first.is_a?(Proc) ? args.first : args
          end
        end

        # Returns the default scopes in a hash of hashes with the key containing the scope name
        # and value containing an array of scope arguments.
        #
        # For example:-
        # {rock: [], electronic: [], released_in_year: ["1980"]}
        def default_scopes
          get_scopes
        end

        private

        def scopes(scopes)
          get_scopes(scopes).each { |name, args| @target = @target.send(name, *args) }
          @target
        end

        # Accepts a symbol or string scope name, hash containing scope name and argument,
        # lambda/proc to execute to return scope(s) or an array of those types
        # and when the argument is blank it uses the class default scopes.
        # Converts the scopes to a hash of hashes with the key containing the scope name
        # and value containing an array of scope arguments.
        def get_scopes(scopes = nil)
          scopes ||= defaults[:scopes]

          Array.wrap(scopes).filter_map do |scope|
            case scope
            when Symbol, String
              {scope => []}
            when Hash
              # ensure values are an array so they can be passed to the scope using splat operator
              scope.transform_values! { |v| Array.wrap(v) }
            when Proc
              # if the class default contains a lambda/proc that returns nil
              # don't call get_scopes as we don't want to end up in an infinite loop
              p_scopes = instance_exec(&scope)
              get_scopes(p_scopes) if p_scopes.present?
            end
          end.reduce({}, :merge)
        end
      end
    end
  end
end
