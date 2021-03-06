#
# Authorization methods for CanCanCan
# https://github.com/CanCanCommunity/cancancan
#
module ActiveManageable
  module Authorization
    module CanCanCan
      extend ActiveSupport::Concern

      included do
        private

        def authorize(record:, action: nil)
          action ||= @current_method
          current_ability.authorize!(action, record)
        end

        def scoped_class
          model_class.accessible_by(current_ability)
        end

        def current_ability
          ::Ability.new(current_user)
        end
      end
    end
  end
end
