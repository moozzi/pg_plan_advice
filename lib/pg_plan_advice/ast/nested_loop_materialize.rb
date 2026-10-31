module PgPlanAdvice
  module Ast
    class NestedLoopMaterialize < Node
      accepts Target, OrderedGroup
      advice_name "NESTED_LOOP_MATERIALIZE"
    end
  end
end
