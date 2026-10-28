module PgPlanAdvice
  module Ast
    class AdviceSet
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes
      end
    end
  end
end
