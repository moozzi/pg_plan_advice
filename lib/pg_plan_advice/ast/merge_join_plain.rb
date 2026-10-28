module PgPlanAdvice
  module Ast
    class MergeJoinPlain
      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "MERGE_JOIN_PLAIN"
      end
    end
  end
end
