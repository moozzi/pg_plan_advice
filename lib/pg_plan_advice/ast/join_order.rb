module PgPlanAdvice
  module Ast
    class JoinOrder
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "JOIN_ORDER"
      end
    end
  end
end
