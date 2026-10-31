module PgPlanAdvice
  module Ast
    class IndexScan < Node
      accepts IndexTarget
      advice_name "INDEX_SCAN"
    end
  end
end
