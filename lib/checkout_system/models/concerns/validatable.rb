# frozen_string_literal: true

module Concerns
  module Validatable
    def self.included(base)
      base.extend ClassMethods
    end

    def assert_class!(var_name, object, klass)
      raise ArgumentError, "Expected a #{klass} for #{var_name}, got #{object.class} instead" unless object.is_a?(klass)
    end

    # TODO: Make equivalent "validate" that stores errors instead of raising an exception
    def validate!
      self.class.validations.each do |attribute_name, klass, message, block|
        value = send(attribute_name)
        assert_class!(attribute_name, value, klass)

        next unless block

        raise ArgumentError, "#{attribute_name} #{message || 'is invalid'}" unless block.call(value)
      end
    end

    module ClassMethods
      attr_reader :validations

      def validates(attribute_name, klass, message = nil, &block)
        @validations ||= []
        @validations << [attribute_name, klass, message, block || nil]
      end

      def validates_non_negative_integer(attribute_name)
        validates(attribute_name, Integer, 'must be greater than or equal to zero') { _1 >= 0 }
      end
    end
  end
end
