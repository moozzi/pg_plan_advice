module PgPlanAdvice
  module Ast
    class NoGather
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "NO_GATHER"
      end
    end
  end
end
