# frozen_string_literal: true

class Product
  include Concerns::Assertable
  include Concerns::CodeIdentifiable

  attr_reader :code, :name, :price

  def initialize(code:, name:, price:)
    @code = code
    @name = name
    @price = price

    validate_code!
    validate_name!
    validate_price!
  end

  private

  def validate_code!
    assert_class!(:code, code, String)

    raise ArgumentError, '"Code" must be a non-empty string' unless code.length.positive?
  end

  def validate_name!
    assert_class!(:name, name, String)

    raise ArgumentError, '"Name" must be a non-empty string' unless name.length.positive?
  end

  def validate_price!
    assert_class!(:price, price, Money)
  end
end
