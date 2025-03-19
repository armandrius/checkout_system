class LineItem
  # TODO don't let pricing rules be exposed as an array. Review attribute accessors
  attr_reader :checkout, :product, :quantity, :final_price, :pricing_rules_applied

  def initialize(product:, quantity: 1, checkout: nil)
    @checkout = checkout
    @product = product
    @quantity = quantity
    @final_price = product.price * quantity
    @pricing_rules_applied = []
  end
end
