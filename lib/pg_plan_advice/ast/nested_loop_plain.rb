module PgPlanAdvice
  module Ast
    class NestedLoopPlain
      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "NESTED_LOOP_PLAIN"
      end
    end
  end
end
