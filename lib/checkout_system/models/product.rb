class Product
  attr_accessor :code, :name, :price

  def initialize(code: nil, name: nil, price: nil)
    # TODO: validate inputs
    @code = code
    @name = name
    @price = price
  end

  def ==(other)
    other.is_a?(Product) && other.code == code
  end
end
