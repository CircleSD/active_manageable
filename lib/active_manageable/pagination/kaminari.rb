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

        # Class option used when determining whether to create a paginatable collection without counting the total number of records
        # within the order of precedence based on the (1) method option, or (2) class option, or (3) configuration option
        def paginate_without_count(without_count = true)
          self.without_count = without_count
        end
      end

      included do
        class_attribute :without_count, instance_writer: false, instance_predicate: false
      end

      private

      def page(opts)
        @target = @target.page(page_number(opts)).per(page_size(opts)).tap do |target|
          target.without_count if paginate_without_count?(opts)
        end
      end

      def page_number(opts)
        opts.try(:[], :number)
      end

      def page_size(opts)
        opts.try(:[], :size) || defaults.dig(:page, :size)
      end

      # Determine whether to create a paginatable collection without counting the total number of records
      # in order of precedence based on the (1) method option, or (2) class option, or (3) configuration option
      def paginate_without_count?(opts)
        [
          opts.try(:[], :without_count),
          without_count,
          ActiveManageable.configuration.paginate_without_count
        ].compact.first
      end
    end
  end
end
