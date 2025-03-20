# frozen_string_literal: true

module Concerns
  module BulkDiscountable
    def self.included(base)
      base.class_eval do
        attr_reader :min_quantity

        validates_non_negative_integer(:min_quantity)
      end
    end

    def applicable?(line_item)
      product_matches?(line_item) && line_item.quantity >= min_quantity
    end
  end
end
