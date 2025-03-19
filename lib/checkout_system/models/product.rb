class Product
  attr_accessor :code, :name, :price

  def initialize(code: nil, name: nil, price: nil)
    # TODO validate inputs
    @code = code
    @name = name
    @price = price
  end

  def ==(another)
    another.is_a?(Product) && another.code == code
  end
end
