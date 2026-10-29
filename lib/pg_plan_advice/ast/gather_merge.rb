module PgPlanAdvice
  module Ast
    class GatherMerge
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "GATHER_MERGE"
      end
    end
  end
end
