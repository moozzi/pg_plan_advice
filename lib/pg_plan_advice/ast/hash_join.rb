module PgPlanAdvice
  module Ast
    class HashJoin < Node
      accepts Target, OrderedGroup
      advice_name "HASH_JOIN"
    end
  end
end
