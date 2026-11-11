module PgPlanAdvice
  module Ast
    class AdviceSet
      attr_reader :nodes

      def initialize(nodes)
        @nodes = nodes
      end

      def to_s
        @nodes.map { |node| "#{node.class.tag}(#{serialize_targets(node.targets)})" }.join(" ")
      end

      def merge(advice_set)
        self.class.new(nodes + advice_set.nodes)
      end

      private

      def serialize_targets(targets)
        targets.map do |target|
          case target
          when Ast::Target, Ast::IndexTarget then target.to_s
          when Ast::OrderedGroup             then "(#{serialize_targets(target.items)})"
          when Ast::UnorderedGroup           then "{#{serialize_targets(target.items)}}"
          else raise InvalidAdviceError, "unable to serialize: #{target.class}"
          end
        end.join(" ")
      end
    end
  end
end
