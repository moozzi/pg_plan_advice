module PgPlanAdvice
  module Ast
    class DoNotScan < Node
      accepts Target
      advice_name "DO_NOT_SCAN"
    end
  end
end
