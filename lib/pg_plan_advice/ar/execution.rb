module PgPlanAdvice
  module AR
    module Execution
      GUC = "pg_plan_advice.advice"

      def self.with_advice(connection, advice)
        return yield if advice.nil? || advice.empty?

        if connection.transaction_open?
          previous = connection.select_value("SELECT current_setting('#{GUC}', true)")
          apply(connection, advice)

          begin
            yield
          ensure
            restore(connection, previous)
          end
        else
          connection.transaction do
            apply(connection, advice)
            yield
          end
        end
      end

      def self.apply(connection, value)
        connection.select_value("SELECT set_config('#{GUC}', #{connection.quote(value)}, true)")
      end

      def self.restore(connection, value)
        apply(connection, value)
      rescue ::ActiveRecord::StatementInvalid
        # ?
      end
    end
  end
end
