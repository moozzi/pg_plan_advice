module PgPlanAdvice
  module Ast
    class SeqScan < Node
      accepts Target
      advice_name "SEQ_SCAN"
    end
  end
end
