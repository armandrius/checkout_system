# frozen_string_literal: true

require 'money'

class Numeric
  Money::Currency.table.each_key do |currency_code_sym|
    define_method(currency_code_sym) do
      Money.from_amount(self, currency_code_sym)
    end
  end
end
