# frozen_string_literal: true

# Active Support Core Extensions
# https://guides.rubyonrails.org/active_support_core_extensions.html
require "active_support/core_ext"
# rails-i18n required for "number.format.separator"
require "rails-i18n"
# flexitime required to parse date & datetime attribute values
require "flexitime"

require_relative "active_manageable/version"
require_relative "active_manageable/configuration"
require_relative "active_manageable/base"
require_relative "active_manageable/methods/index"
require_relative "active_manageable/methods/show"
require_relative "active_manageable/methods/new"
require_relative "active_manageable/methods/create"
require_relative "active_manageable/methods/edit"
require_relative "active_manageable/methods/update"
require_relative "active_manageable/methods/destroy"
require_relative "active_manageable/methods/auxiliary/includes"
require_relative "active_manageable/methods/auxiliary/model_attributes"
require_relative "active_manageable/methods/auxiliary/order"
require_relative "active_manageable/methods/auxiliary/scopes"
require_relative "active_manageable/methods/auxiliary/select"
require_relative "active_manageable/methods/auxiliary/unique_search"
require_relative "active_manageable/authorization/pundit"
require_relative "active_manageable/authorization/cancancan"
require_relative "active_manageable/search/ransack"
require_relative "active_manageable/pagination/kaminari"

module ActiveManageable
  ALL_METHODS = "*"

  thread_mattr_accessor :current_user

  mattr_accessor :configuration
  @@configuration = Configuration.new

  def self.config
    yield configuration
  end
end
