# frozen_string_literal: true

require 'money'

class Product
  include Concerns::Validatable
  include Concerns::CodeIdentifiable

  attr_reader :name, :price

  validates(:name, String, 'cannot be empty') { |name| name.length.positive? }
  validates :price, Money

  def initialize(code:, name:, price:)
    @code = code
    @name = name
    @price = price

    validate!
  end
end
