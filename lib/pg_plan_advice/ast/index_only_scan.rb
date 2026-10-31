module PgPlanAdvice
  module Ast
    class IndexOnlyScan < Node
      accepts IndexTarget
      advice_name "INDEX_ONLY_SCAN"
    end
  end
end
