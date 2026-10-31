module PgPlanAdvice
  module Ast
    class NestedLoopMemoize < Node
      accepts Target, OrderedGroup
      advice_name "NESTED_LOOP_MEMOIZE"
    end
  end
end
