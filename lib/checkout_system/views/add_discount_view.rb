# frozen_string_literal: true

class AddDiscountView
  def render
    puts '\nAvailable discounts:'
    puts '1. Buy-One-Get-One-Free on Green tea'
    puts '2. Bulk discount on Strawberries (3 or more for £4.50 each)'
    puts '3. Bulk percent discount on Coffee (3 or more for 33.33% off)'

    print '\nSelect discount (1-3): '
    gets.strip
  end
end
