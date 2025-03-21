# frozen_string_literal: true

class BuyProductsView
  def initialize(products)
    @products = products
  end

  def render
    ShowAvailableProductsPartialView.new(@products).render

    print 'Type a product code and press enter: '
    gets.strip.upcase
  end
end
