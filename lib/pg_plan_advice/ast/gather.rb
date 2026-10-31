module PgPlanAdvice
  module Ast
    class Gather < Node
      accepts Target, OrderedGroup
      advice_name "GATHER"
    end
  end
end
