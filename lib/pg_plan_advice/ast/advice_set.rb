module PgPlanAdvice
  module Ast
    class AdviceSet
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |node| "#{node.class.advice_name}(#{node.targets})" }.join(" ")
      end
    end
  end
end
