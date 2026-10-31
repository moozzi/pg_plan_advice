module PgPlanAdvice
  module Ast
    class BitmapHeapScan < Node
      accepts Target
      advice_name "BITMAP_HEAP_SCAN"
    end
  end
end
