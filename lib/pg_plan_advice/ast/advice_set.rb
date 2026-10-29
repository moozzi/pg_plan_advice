module PgPlanAdvice
  module Ast
    class AdviceSet
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |node| "#{node.class.advice_name}(#{serialize_targets(node.targets)})" }.join(" ")
      end

      private

      def serialize_targets(targets)
        targets.map do |target|
          case target
          when Ast::Target         then target.alias_name
          when Ast::OrderedGroup   then "(#{serialize_targets(target.items)})"
          when Ast::UnorderedGroup then "{#{serialize_targets(target.items)}}"
          else raise "invalid target"
          end
        end.join(" ")
      end
    end
  end
end
