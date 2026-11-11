module PgPlanAdvice
  module Ast
    Target = Data.define(:alias_name, :occurrence_number, :partition_schema, :partition_name, :plan_name) do
      def initialize(alias_name:, occurrence_number: nil, partition_schema: nil, partition_name: nil, plan_name: nil)
        invalid!("alias_name can't be empty") if alias_name.empty?

        if partition_schema.nil? != partition_name.nil?
          invalid!("partition_schema and partition_name must be given together")
        end

        unless occurrence_number.nil? || positive_integer?(occurrence_number)
          invalid!("occurrence_number must be a positive integer, got: #{occurrence_number.inspect}")
        end

        super
      end

      def to_s
        result = Identifier.quote(alias_name)
        result += "##{occurrence_number}" if occurrence_number
        result += "/#{Identifier.quote(partition_schema)}" if partition_schema
        result += ".#{Identifier.quote(partition_name)}" if partition_name
        result += "@#{Identifier.quote(plan_name)}" if plan_name

        result
      end

      private

      def positive_integer?(value)
        value.is_a?(Integer) && value.positive?
      end

      def invalid!(message)
        raise InvalidAdviceError, "Target #{message}"
      end
    end
  end
end
