module PgPlanAdvice
  module Ast
    class SemijoinNonUnique
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "SEMIJOIN_UNON_NIQUE"
      end
    end
  end
end
