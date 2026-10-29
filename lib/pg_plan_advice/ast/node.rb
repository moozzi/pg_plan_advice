module PgPlanAdvice
  module Ast
    class Node < Data.define(:targets)
      def advice_name
        self.class.advice_name
      end

      def validate_nested_items!(items)
        items.each do |item|
          case item
          when Target then next
          when OrderedGroup
            raise InvalidAdviceError, "#{advice_name}: does not allow nesting" if item.items.any? do |item|
              !item.is_a?(Target)
            end
          else
            raise InvalidAdviceError, "#{advice_name}: invalid target: #{item.inspect}"
          end
        end
      end
    end
  end
end
