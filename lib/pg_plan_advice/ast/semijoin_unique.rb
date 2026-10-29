module PgPlanAdvice
  module Ast
    class SemijoinUnique
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "SEMIJOIN_UNIQUE"
      end
    end
  end
end
