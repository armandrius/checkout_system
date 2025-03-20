# frozen_string_literal: true

module Concerns
  module Assertable
    def assert_class!(var_name, object, klass)
      raise ArgumentError, "Expected a #{klass} for #{var_name}, got #{object.class} instead" unless object.is_a?(klass)
    end
  end
end
