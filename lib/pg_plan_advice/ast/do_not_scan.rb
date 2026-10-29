module PgPlanAdvice
  module Ast
    class DoNotScan
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "DO_NOT_SCAN"
      end
    end
  end
end
