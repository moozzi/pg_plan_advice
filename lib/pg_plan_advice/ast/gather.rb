module PgPlanAdvice
  module Ast
    class Gather
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "GATHER"
      end
    end
  end
end
