module PgPlanAdvice
  module Ast
    Target = Data.define(:alias_name, :occurrence_number, :partition_schema, :partition_name, :plan_name) do
      def initialize(alias_name:, occurrence_number: nil, partition_schema: nil, partition_name: nil, plan_name: nil)
        super
      end
    end
  end
end
