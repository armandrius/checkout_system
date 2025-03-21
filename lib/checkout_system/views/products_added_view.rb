# frozen_string_literal: true

class ProductsAddedView
  def initialize(product, quantity)
    @product = product
    @quantity = quantity
  end

  def render
    puts "#{@quantity} #{@product.name}(s) added to your basket."
  end
end
