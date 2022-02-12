#
# Search methods for Ransack
# https://github.com/activerecord-hackery/ransack
#
module ActiveManageable
  module Search
    module Ransack
      extend ActiveSupport::Concern

      included do
        attr_reader :ransack

        initialize_state_methods :initialize_ransack_state

        private

        def initialize_ransack_state
          @ransack = nil
        end

        def search(opts)
          @ransack = @target.ransack(opts)
          @target = @ransack.result
        end

        # Perform standard index module ordering when no ransack search params provided
        # or no ransack sorts params provided
        def order(attributes)
          if @ransack.blank? || @ransack.sorts.empty?
            @target = @target.order(get_order_attributes(attributes))
          else
            @target
          end
        end
      end
    end
  end
end
