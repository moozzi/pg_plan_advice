module PgPlanAdvice
  module Ast
    class NestedLoopMaterialize
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "NESTED_LOOP_MATERIALIZE"
      end
    end
  end
end
