# frozen_string_literal: true

class Product
  attr_reader :code, :name, :price

  def initialize(code:, name:, price:)
    # TODO: validate inputs
    @code = code
    @name = name
    @price = price
  end

  def ==(other)
    other.is_a?(Product) && other.code == code
  end
end
