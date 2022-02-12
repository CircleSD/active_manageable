#
# Pagination methods for Kaminari
# https://github.com/kaminari/kaminari
#
module ActiveManageable
  module Pagination
    module Kaminari
      extend ActiveSupport::Concern

      class_methods do
        # Sets the default page size to use when fetching records in the index method
        # if the index :options argument does not contain a :page hash with :size key;
        # accepting an integer.
        #
        # For example:-
        #   default_page_size 5
        def default_page_size(page_size)
          defaults[:page] = {size: page_size.to_i}
        end
      end

      included do
        private

        def page(opts)
          @target = @target.page(page_number(opts)).per(page_size(opts))
        end

        def page_number(opts)
          opts.try(:[], :number)
        end

        def page_size(opts)
          opts.try(:[], :size) || defaults.dig(:page, :size)
        end
      end
    end
  end
end
