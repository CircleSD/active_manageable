module ActiveManageable
  module Methods
    module Auxiliary
      module Includes
        extend ActiveSupport::Concern

        class_methods do
          # Sets the default associations to eager load when fetching records
          # in the index, show, edit, update and destroy methods
          # if the methods :options argument does not contain a :includes key;
          # accepting a single, array or hash of association names;
          # optional :methods in which to eager load the associations;
          # and optional :loading_method if this needs to be different to the configuration :default_loading_method
          # also accepting a lambda/proc to execute to return association names and optional :methods
          #
          # For example:-
          #   default_includes :songs
          #   default_includes :songs, :artist, methods: :show
          #   default_includes songs: :artist, loading_method: :eager_load, methods: [:index, :edit]
          #   default_includes -> { includes_associations }
          #   default_includes -> { includes_associations }, methods: [:index, :edit]
          def default_includes(*associations)
            options = extract_includes_options!(associations)
            loading_method = options[:loading_method] || ActiveManageable.configuration.default_loading_method
            assoc = associations.first.is_a?(Proc) ? associations.first : associations
            value = {associations: assoc, loading_method: loading_method}
            add_method_defaults(key: :includes, value: value, methods: options[:methods])
          end

          private

          # As the associations argument may contain a single hash containing both
          # the associations and options we cannot use the array extract_options! method
          # as this removes the last element in the array if it's a hash.
          #
          # For example :-
          # default_includes songs: :artist, loading_method: :preload, methods: :index
          # results in an argument value of :-
          # [{:songs=>:artist, :loading_method=>:preload, :methods=>:index}]
          #
          # So instead this method, like extract_options!, ascertains
          # if the last element in the array is a hash but then it extracts
          # the specific options and only removes the last element if it's empty.
          # Therefore catering for the variety of association formats
          # and potential presence of the options eg.
          #
          # [:songs, :artist, {:loading_method=>:preload, :methods=>"index"}]
          # [:artist, {:songs=>:artist}, {:loading_method=>:preload, :methods=>:index}]
          # [{:songs=>:artist, :loading_method=>:preload, :methods=>:index}]
          def extract_includes_options!(associations)
            if associations.last.is_a?(Hash)
              options = associations.last.extract!(:loading_method, :methods)
              associations.pop if associations.last.empty?
              options
            else
              {}
            end
          end
        end

        private

        # Accepts either an array/hash of associations
        # or a hash with associations and loading_method keys
        # so it's possible to specify loading_method on a per request basis.
        # Uses associations and loading_method from opts
        # or defaults for the method or defaults for all methods
        # or configuration default loading_method.
        def includes(opts)
          unless opts.is_a?(Hash) && opts.key?(:associations)
            opts = {associations: opts}
          end
          associations = opts[:associations] || get_default_includes_associations
          if associations.present?
            loading_method = opts[:loading_method] || get_default_includes_loading_method
            @target = @target.send(loading_method, associations)
          else
            @target
          end
        end

        def get_default_includes_associations
          includes = defaults[:includes] || {}
          associations = includes.dig(@current_method, :associations) || includes.dig(:all, :associations)
          associations.is_a?(Proc) ? instance_exec(&associations) : associations
        end

        def get_default_includes_loading_method
          includes = defaults[:includes] || {}
          loading_method = includes.dig(@current_method, :loading_method) || includes.dig(:all, :loading_method)
          loading_method || ActiveManageable.configuration.default_loading_method
        end
      end
    end
  end
end
