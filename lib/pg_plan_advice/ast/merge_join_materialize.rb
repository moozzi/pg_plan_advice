module PgPlanAdvice
  module Ast
    class MergeJoinMaterialize
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "MERGE_JOIN_MATERIALIZE"
      end
    end
  end
end
