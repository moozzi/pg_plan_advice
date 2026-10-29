module PgPlanAdvice
  module Ast
    class Partitionwise
      attr_reader :targets

      def initialize(targets)
        @targets = targets
      end

      def self.advice_name
        "PARTITIONWISE"
      end
    end
  end
end
