# frozen_string_literal: true

module Concerns
  module CodeIdentifiable
    def ==(other)
      other.is_a?(self.class) && other.code == code
    end
  end
end
