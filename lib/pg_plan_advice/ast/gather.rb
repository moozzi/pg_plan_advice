module PgPlanAdvice
  module Ast
    class Gather < Node
      def initialize(targets:)
        raise InvalidAdviceError, "#{advice_name} targets must not be empty" if targets.empty?

        validate_nested_items!(targets)

        super(targets: targets.dup.freeze)
      end

      def self.advice_name
        "GATHER"
      end
    end
  end
end
