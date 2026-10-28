module PgPlanAdvice
  module Ast
    class NestedLoopMaterialize
      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "NESTED_LOOP_MATERIALIZE"
      end
    end
  end
end
