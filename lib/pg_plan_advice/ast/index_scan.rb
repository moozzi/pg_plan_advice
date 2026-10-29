module PgPlanAdvice
  module Ast
    class IndexScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "INDEX_SCAN"
      end
    end
  end
end
