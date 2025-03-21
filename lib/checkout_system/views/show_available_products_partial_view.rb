# frozen_string_literal: true

class ShowAvailableProductsPartialView
  def initialize(products)
    @products = products
  end

  def render
    puts 'Available Products:'
    puts 'Code | Name         | Price'
    @products.each do |p|
      puts format('%<code>-5s| %<name>-13s| %<price>s', { code: p.code, name: p.name, price: p.price.format })
    end
  end
end
