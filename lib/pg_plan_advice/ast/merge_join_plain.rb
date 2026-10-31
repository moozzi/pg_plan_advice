module PgPlanAdvice
  module Ast
    class MergeJoinPlain < Node
      accepts Target, OrderedGroup
      advice_name "MERGE_JOIN_PLAIN"
    end
  end
end
