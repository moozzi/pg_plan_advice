module PgPlanAdvice
  module Ast
    class SeqScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "SEQ_SCAN"
      end
    end
  end
end
