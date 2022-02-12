module ActiveManageable
  AUTHORIZATION_LIBRARIES = %i[pundit cancancan].freeze
  SEARCH_LIBRARIES = %i[ransack].freeze
  PAGINATION_LIBRARIES = %i[kaminari].freeze
  LOADING_METHODS = %i[includes preload eager_load].freeze

  class Configuration
    attr_reader :authorization_library, :search_library, :pagination_library, :default_loading_method
    attr_accessor :subclass_suffix

    def initialize
      @default_loading_method = :includes
      @subclass_suffix = "Manager"
    end

    def authorization_library=(authorization_library)
      raise ArgumentError.new("Invalid authorization library") unless authorization_library_valid?(authorization_library)
      @authorization_library = authorization_library.to_sym
    end

    def search_library=(search_library)
      raise ArgumentError.new("Invalid search library") unless search_library_valid?(search_library)
      @search_library = search_library.to_sym
    end

    def pagination_library=(pagination_library)
      raise ArgumentError.new("Invalid pagination library") unless pagination_library_valid?(pagination_library)
      @pagination_library = pagination_library.to_sym
    end

    def default_loading_method=(default_loading_method)
      raise ArgumentError.new("Invalid method for eager loading") unless default_loading_method_valid?(default_loading_method)
      @default_loading_method = default_loading_method.to_sym
    end

    private

    def authorization_library_valid?(authorization_library)
      option_valid?(AUTHORIZATION_LIBRARIES, authorization_library)
    end

    def search_library_valid?(search_library)
      option_valid?(SEARCH_LIBRARIES, search_library)
    end

    def pagination_library_valid?(pagination_library)
      option_valid?(PAGINATION_LIBRARIES, pagination_library)
    end

    def default_loading_method_valid?(default_loading_method)
      option_valid?(LOADING_METHODS, default_loading_method)
    end

    def option_valid?(options, option)
      option.present? && options.include?(option.to_s.to_sym)
    end
  end
end
