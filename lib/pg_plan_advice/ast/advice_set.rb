module PgPlanAdvice
  module Ast
    class AdviceSet
      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |node| "#{node.class.tag}(#{serialize_targets(node.targets)})" }.join(" ")
      end

      private

      def serialize_targets(targets)
        targets.map do |target|
          case target
          when Ast::Target         then target.to_s
          when Ast::IndexTarget    then "#{serialize_targets([target.target])} #{target.index_name}"
          when Ast::OrderedGroup   then "(#{serialize_targets(target.items)})"
          when Ast::UnorderedGroup then "{#{serialize_targets(target.items)}}"
          else raise "invalid target #{target.class}"
          end
        end.join(" ")
      end
    end
  end
end
