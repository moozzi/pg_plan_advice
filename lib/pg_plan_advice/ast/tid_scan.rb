module PgPlanAdvice
  module Ast
    class TidScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "TID_SCAN"
      end
    end
  end
end
