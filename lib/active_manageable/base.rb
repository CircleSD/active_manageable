module ActiveManageable
  class Base
    class_attribute :model_class, instance_writer: false, instance_predicate: false
    class_attribute :defaults, instance_writer: false, instance_predicate: false
    class_attribute :module_initialize_state_methods, instance_writer: false, instance_predicate: false

    attr_accessor :target
    attr_reader :current_method, :attributes, :options

    # target provides a common variable to use within the CRUD, auxiliary & library methods
    # whereas the object & collection methods provide less ambiguous external access
    alias_attribute :object, :target
    alias_attribute :collection, :target

    class << self
      # Ruby method called when a child class inherits from a parent class
      def inherited(subclass)
        super
        # necessary to set default value here rather than in class_attribute declaration
        # otherwise all subclasses share the same hash/array instance
        subclass.defaults = {}
        subclass.module_initialize_state_methods = []
      end

      delegate :current_user, to: ActiveManageable

      # Include the required action methods in your class
      # either all methods using the ActiveManageable::ALL_METHODS constant
      # or selective methods from :index, :show, :new, :create, :edit, :update, :destroy
      # and optionally set the :model_class
      #
      # For example:-
      #   manageable ActiveManageable::ALL_METHODS
      #   manageable ActiveManageable::ALL_METHODS, model_class: Album
      #   manageable :index, :show
      def manageable(*methods)
        options = methods.extract_options!.dup

        methods = ActiveManageable::Methods.constants if methods[0] == ActiveManageable::ALL_METHODS

        methods.each do |method|
          include ActiveManageable::Methods.const_get(method.to_s.classify)
        end

        include_authorization
        include_search
        include_pagination

        options.each { |key, value| send(:"#{key}=", value) }

        set_model_class
      end

      private

      def include_authorization
        case ActiveManageable.configuration.authorization_library
        when :pundit
          include ActiveManageable::Authorization::Pundit
        when :cancancan
          include ActiveManageable::Authorization::CanCanCan
        when Module
          include ActiveManageable.configuration.authorization_library
        end
      end

      def include_search
        case ActiveManageable.configuration.search_library
        when :ransack
          include ActiveManageable::Search::Ransack
        when Module
          include ActiveManageable.configuration.search_library
        end
      end

      def include_pagination
        case ActiveManageable.configuration.pagination_library
        when :kaminari
          include ActiveManageable::Pagination::Kaminari
        when Module
          include ActiveManageable.configuration.pagination_library
        end
      end

      def set_model_class
        self.model_class ||= begin
          if name.end_with?(ActiveManageable.configuration.subclass_suffix)
            name.chomp(ActiveManageable.configuration.subclass_suffix).classify.constantize
          end
        rescue NameError
        end
      end

      def initialize_state_methods(*methods)
        module_initialize_state_methods.concat(methods)
      end

      def add_method_defaults(key:, value:, methods:)
        methods = Array.wrap(methods).map(&:to_sym)
        methods << :all if methods.empty?
        defaults[key] ||= {}
        methods.each { |method| defaults[key][method] = value }
      end
    end

    def current_user
      @current_user || ActiveManageable.current_user
    end

    def with_current_user(user)
      @current_user = user
      yield
    ensure
      @current_user = nil
    end

    private

    def action_scope
      model_class
    end

    def initialize_state(attributes: {}, options: {})
      @target = nil
      @current_method = calling_method
      @attributes = normalize_attributes(state_argument_to_hwia(attributes))
      @options = state_argument_to_hwia(options)
      module_initialize_state_methods.each { |method| send(method) }
    end

    def authorize(record:, action: nil)
    end

    # Returns the name of the calling method
    # using caller_locations that returns the current execution stack
    # and catering for inheritance and two occurrences of initialize_state in the execution stack
    # when the ransack module is included as it has its own definition of the method that calls super
    # https://www.lucascaton.com.br/2016/11/04/ruby-how-to-get-the-name-of-the-calling-method
    def calling_method
      my_caller = caller_locations(1..1).first.label
      caller_locations[1..].find { |location| location.label != my_caller }.label.to_sym
    end

    # Converts a state argument to a ActiveSupport::HashWithIndifferentAccess.
    # The purpose of the method is to return a duplicate object for arguments like the attributes
    # so that any changes that are made internally do not affect the source object.
    #
    # For a Hash returns an ActiveSupport::HashWithIndifferentAccess.
    # For a ActiveSupport::HashWithIndifferentAccess returns a duplicate ActiveSupport::HashWithIndifferentAccess.
    # For an ActionController::Parameters returns a safe ActiveSupport::HashWithIndifferentAccess
    # representation of the parameters with all unpermitted keys removed.
    #
    # NB: For an ActionController::Parameters we experimented with using the deep_dup method
    # to return a duplicate ActionController::Parameters but this caused issues
    # for the attributes argument when the params had been permiited and then nested params are replaced with a hash.
    # That would be fine if the attributes were then used for mass assignment, however,
    # first we call normalize_attribute_values which uses the each method
    # which converts all hashes into ActionController::Parameters with the permitted attribute set to false
    # so when performing mass assignment that resulted in a ActiveModel::ForbiddenAttributesError.
    def state_argument_to_hwia(arg)
      case arg
      when Hash
        arg.with_indifferent_access
      when action_controller_params?
        arg.to_h
      else
        arg
      end
    end

    # Returns true if the object is an ActionController::Parameters
    # using class.name so the gem does not need a dependency on ActionPack simply for a case statement
    def action_controller_params?
      ->(object) { object.class.name == "ActionController::Parameters" }
    end

    def normalize_attributes(attributes)
      normalize_attribute_values(model_class, attributes)
    end

    # Parse date & datetime attribute values and normalize decimal separator for numeric attributes
    def normalize_attribute_values(model_class, attributes)
      case attributes
      when Hash
        attributes.each do |key, value|
          if key.end_with?("_attributes")
            association_class = model_association_class(model_class, key.delete_suffix("_attributes"))
            normalize_attribute_values(association_class, value) if association_class.present?
          else
            case model_attribute_type(model_class, key)
            when :date
              attributes[key] = Flexitime.parse(value).try(:to_date) || value
            when :datetime
              attributes[key] = Flexitime.parse(value) || value
            when :decimal, :float
              attributes[key] = normalize_decimal_separator(value)
            end
          end
        end
      when Array
        attributes.each { |attrs| normalize_attribute_values(model_class, attrs) }
      end
    end

    def model_association_class(model_class, association_name)
      model_class.reflect_on_association(association_name).try(:class_name).try(:constantize)
    end

    # Returns the type of the attribute with the given name
    # and could be overridden by a child class in order to
    # return the type of both column and non-column based attributes
    # when a non-column based attribute value needed to be normalized
    def model_attribute_type(model_class, attribute_name)
      model_class.type_for_attribute(attribute_name).type
    end

    # Returns a value with a comma separator replaced with a point separator
    def normalize_decimal_separator(value)
      normalize_decimal_separator?(value) ? value.tr(",", ".") : value
    end

    # Normalize decimal separator when the locale number separator is a comma
    # and the value does not include a point and includes only one comma
    def normalize_decimal_separator?(value)
      I18n.t("number.format.separator") == "," &&
        value.to_s.count(".") == 0 && value.to_s.count(",") == 1
    end
  end
end
