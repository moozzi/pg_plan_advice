module PgPlanAdvice
  module Ast
    class Partitionwise < Node
      accepts Target, OrderedGroup
      advice_name "PARTITIONWISE"
    end
  end
end
