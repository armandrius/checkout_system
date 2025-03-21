# frozen_string_literal: true

class ShopApp
  def initialize
    @products = [
      Product.new(code: 'CF1', name: 'Coffee', price: 11.23.gbp),
      Product.new(code: 'GR1', name: 'Green tea', price: 3.11.gbp),
      Product.new(code: 'SR1', name: 'Strawberries', price: 5.00.gbp)
    ]
    @pricing_rules = []
    @checkout = Checkout.new(@pricing_rules)
  end

  def run
    WelcomeView.new.render

    main
  end

  private

  def main # rubocop:disable Metrics/MethodLength
    loop do
      user_input = MainView.new(@checkout.total).render
      case user_input
      when 'L' then buy_products_by_list
      when 'B' then buy_products
      when 'D' then add_discount
      when 'E' then empty_basket
      when 'Q'
        ExitView.new(@checkout.total).render
        break
      else
        InvalidChoiceView.new.render
      end
    end
  end

  def buy_products_by_list
    codes = BuyProductsByListView.new(@products).render
    codes.each do |code|
      product = @products.find { |p| p.code == code.strip.upcase }
      next ProductCodeNotFoundView.new(code).render unless product

      @checkout.scan(product)
      ProductAddedView.new(product).render
    end
  end

  def buy_products
    code = BuyProductsView.new(@products).render
    product = @products.find { |p| p.code == code }

    return ProductCodeNotFoundView.new(code).render unless product

    quantity = HowManyView.new.render

    quantity.times { @checkout.scan(product) }

    ProductsAddedView.new(product, quantity).render
  end

  def add_discount
    discount_choice = AddDiscountView.new.render
    case discount_choice
    when '1' then add_bogof_discount
    when '2' then add_bulk_fixed_discount
    when '3' then add_bulk_percent_discount
    else InvalidDiscountView.new.render
    end
  end

  def add_bogof_discount
    product = @products.find { |p| p.code == 'GR1' }
    pricing_rule = PricingRules::BuyNGetM.new(
      code: 'BOGOF', product:, buy: 1, get: 1
    )
    @checkout.add_pricing_rules(pricing_rule)
    DiscountAddedView.new(pricing_rule).render
  end

  def add_bulk_fixed_discount
    product = @products.find { |p| p.code == 'SR1' }
    pricing_rule = PricingRules::BulkFixedDiscount.new(
      code: 'SR1_DISCOUNT', product:, min_quantity: 3, price: 4.50.gbp
    )
    @checkout.add_pricing_rules(pricing_rule)
    DiscountAddedView.new(pricing_rule).render
  end

  def add_bulk_percent_discount
    product = @products.find { |p| p.code == 'CF1' }
    pricing_rule = PricingRules::BulkPercentDiscount.new(
      code: 'CF1_DISCOUNT', product:, min_quantity: 3, discount_percentage: Rational(100, 3)
    )
    @checkout.add_pricing_rules(pricing_rule)
    DiscountAddedView.new(pricing_rule).render
  end

  def empty_basket
    @checkout.empty
    EmptyBasketView.new.render
  end
end
