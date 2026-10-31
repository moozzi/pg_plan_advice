module PgPlanAdvice
  module Ast
    class SemijoinUnique < Node
      accepts Target, OrderedGroup
      advice_name "SEMIJOIN_UNIQUE"
    end
  end
end
