#
# Authorization methods for Pundit
# https://github.com/varvet/pundit
#
module ActiveManageable
  module Authorization
    module Pundit
      extend ActiveSupport::Concern

      included do
        private

        def authorize(record:, action: nil)
          action ||= authorize_action
          ::Pundit.authorize(current_user, record, action)
        end

        def authorization_scope
          ::Pundit.policy_scope(current_user, model_class)
        end

        def authorize_action
          "#{@current_method}?".to_sym
        end
      end
    end
  end
end
