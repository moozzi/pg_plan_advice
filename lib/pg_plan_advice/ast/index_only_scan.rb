module PgPlanAdvice
  module Ast
    class IndexOnlyScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "INDEX_ONLY_SCAN"
      end
    end
  end
end
