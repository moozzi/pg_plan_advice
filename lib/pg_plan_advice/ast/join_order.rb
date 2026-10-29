module PgPlanAdvice
  module Ast
    class JoinOrder < Node
      def initialize(targets:)
        raise InvalidAdviceError, "#{advice_name} targets must not be empty" if targets.empty?

        validate_join_order!(targets)

        super(targets: targets.dup.freeze)
      end

      def self.advice_name
        "JOIN_ORDER"
      end

      def validate_join_order!(items)
        raise InvalidAdviceError, "#{advice_name} sublist must not be empty" if items.empty?

        items.each do |item|
          case item
          when Target
            next
          when OrderedGroup
            validate_join_order!(item.items)
          when UnorderedGroup
            nested = item.items.reject { _1.is_a?(Target) }
            unless nested.empty?
              raise InvalidAdviceError, "#{advice_name}: {} sublist may contain only targets, got: #{nested.inspect}"
            end
          else
            raise InvalidAdviceError, "#{advice_name}: invalid item #{item.inspect}"
          end
        end
      end
    end
  end
end
