# frozen_string_literal: true

class BuyProductsByListView
  def initialize(products)
    @products = products
  end

  def render
    ShowAvailableProductsPartialView.new(@products).render
    print 'Type a list of product codes separated by commas and press enter: '
    gets.strip.split(',')
  end
end
