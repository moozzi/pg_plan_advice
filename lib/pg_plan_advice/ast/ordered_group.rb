module PgPlanAdvice
  module Ast
    OrderedGroup = Data.define(:items) do
      def initialize(items:)
        raise InvalidAdviceError, "OrderedGroup must not be empty" if items.empty?

        super
      end
    end
  end
end
