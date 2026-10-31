module PgPlanAdvice
  module Ast
    class NestedLoopPlain < Node
      accepts Target, OrderedGroup
      advice_name "NESTED_LOOP_PLAIN"
    end
  end
end
