module PgPlanAdvice
  module Ast
    class SemijoinNonUnique < Node
      accepts Target, OrderedGroup
      advice_name "SEMIJOIN_NON_UNIQUE"
    end
  end
end
