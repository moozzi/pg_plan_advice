module PgPlanAdvice
  module Ast
    class MergeJoinMaterialize < Node
      accepts Target, OrderedGroup
      advice_name "MERGE_JOIN_MATERIALIZE"
    end
  end
end
