module PgPlanAdvice
  module Ast
    class BitmapHeapScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "BITMAP_HEAP_SCAN"
      end
    end
  end
end
