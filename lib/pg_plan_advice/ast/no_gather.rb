module PgPlanAdvice
  module Ast
    class NoGather < Node
      accepts Target
      advice_name "NO_GATHER"
    end
  end
end
