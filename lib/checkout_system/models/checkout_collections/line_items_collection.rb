# frozen_string_literal: true

module CheckoutCollections
  class LineItemsCollection
    include Concerns::Assertable

    def initialize
      @indexed_line_items = {}
    end

    def products
      @indexed_line_items.values.map(&:product)
    end

    def total_items
      @indexed_line_items.values.sum(&:quantity)
    end

    def original_price
      @indexed_line_items.values.sum(&:price)
    end

    def final_price
      @indexed_line_items.values.sum(&:final_price)
    end

    def quantity(product)
      assert_class!(:product, product, Product)

      @indexed_line_items[product.code]&.quantity || 0
    end

    def append_product(product)
      assert_class!(:product, product, Product)
      assert_same_currency!(product)

      if @indexed_line_items.key?(product.code)
        @indexed_line_items[product.code].increment
      else
        @indexed_line_items[product.code] = LineItem.new(product:)
      end
    end

    def each(&)
      @indexed_line_items.values.each(&)
    end

    def apply_pricing_rules(pricing_rules_list)
      pricing_rules_list.each do |code, pricing_rules|
        next unless (line_item = @indexed_line_items[code])

        pricing_rules.each do |pricing_rule|
          line_item.apply_pricing_rule(pricing_rule)
        end
      end
    end

    private

    def assert_same_currency!(product)
      return true if @indexed_line_items.empty?

      first_product = @indexed_line_items.values.first.product
      return true if first_product.price.currency == product.price.currency

      raise ArgumentError, 'Products must have the same currency'
    end
  end
end
