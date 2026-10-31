module PgPlanAdvice
  module Ast
    UnorderedGroup = Data.define(:items) do
      def initialize(items:)
        raise InvalidAdviceError, "UnorderedGroup must not be empty" if items.empty?

        super
      end
    end
  end
end
