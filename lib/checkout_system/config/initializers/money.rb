# frozen_string_literal: true

require 'bigdecimal'
require 'money'

Money.rounding_mode = BigDecimal::ROUND_HALF_UP
