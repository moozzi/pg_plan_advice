module PgPlanAdvice
  module Ast
    class ForeignJoin
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "FOREIGN_JOIN"
      end
    end
  end
end
