module PgPlanAdvice
  module Ast
    class GatherMerge < Node
      accepts Target, OrderedGroup
      advice_name "GATHER_MERGE"
    end
  end
end
