module PgPlanAdvice
  module Ast
    class HashJoin
      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "HASH_JOIN"
      end
    end
  end
end
