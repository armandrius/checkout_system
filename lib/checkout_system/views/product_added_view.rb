# frozen_string_literal: true

class ProductAddedView
  def initialize(product)
    @product = product
  end

  def render
    puts "#{@product.name} added to your basket."
  end
end
