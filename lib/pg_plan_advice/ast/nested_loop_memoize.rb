module PgPlanAdvice
  module Ast
    class NestedLoopMemoize
      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "NESTED_LOOP_MEMOIZE"
      end
    end
  end
end
