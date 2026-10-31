module PgPlanAdvice
  module Ast
    class TidScan < Node
      accepts Target
      advice_name "TID_SCAN"
    end
  end
end
