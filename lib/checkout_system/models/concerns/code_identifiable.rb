# frozen_string_literal: true

module Concerns
  module CodeIdentifiable
    def self.included(base)
      base.class_eval do
        attr_reader :code

        validates(:code, String, 'cannot be empty') { |code| code.length.positive? }
      end
    end

    def ==(other)
      other.is_a?(self.class) && other.code == code
    end
  end
end
