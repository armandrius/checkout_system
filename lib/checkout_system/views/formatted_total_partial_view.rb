# frozen_string_literal: true

class FormattedTotalPartialView
  def initialize(total)
    @total = total
  end

  def render
    case @total
    when Money
      @total.format
    else
      @total
    end
  end
end
