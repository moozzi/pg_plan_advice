module PgPlanAdvice
  module Ast
    class BitmapHeapScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "BitmapHeapScan"
      end
    end
  end
end
