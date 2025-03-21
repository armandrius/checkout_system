# frozen_string_literal: true

class ProductCodeNotFoundView
  def initialize(code)
    @code = code
  end

  def render
    puts "Product with code #{@code} not found!"
  end
end
