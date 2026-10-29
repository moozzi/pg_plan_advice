module PgPlanAdvice
  module Ast
    Target = Data.define(:alias_name, :occurrence_number, :partition_schema, :partition_name, :plan_name) do
      def initialize(alias_name:, occurrence_number: nil, partition_schema: nil, partition_name: nil, plan_name: nil)
        super
      end

      def to_s
        result = alias_name.to_s
        result += "##{occurrence_number}" if occurrence_number
        result += "/#{partition_schema}" if partition_schema
        result += ".#{partition_name}" if partition_name
        result += "@#{plan_name}" if plan_name

        result
      end
    end
  end
end
