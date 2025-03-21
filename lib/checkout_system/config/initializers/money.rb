# frozen_string_literal: true

require 'bigdecimal'
require 'money'

Money.rounding_mode = BigDecimal::ROUND_HALF_UP
Money.locale_backend = :i18n
I18n.available_locales = [:en]
I18n.default_locale = :en
