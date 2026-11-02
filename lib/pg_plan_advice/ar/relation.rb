module PgPlanAdvice
  module AR
    module Relation
      attr_accessor :plan_advice_value

      def plan_advice(&blk)
        advice = PgPlanAdvice.build(resolver: Resolver.new(klass), &blk)
        spawn.tap do |rel|
          rel.plan_advice_value = plan_advice_value ? plan_advice_value.merge(advice) : advice
        end
      end

      def exec_explain(...) = with_plan_advice { super }
      def pluck(...)        = with_plan_advice { super }
      def exists?(...)      = with_plan_advice { super }
      def update_all(...)   = with_plan_advice { super }
      def delete_all(...)   = with_plan_advice { super }
      def calculate(...)    = with_plan_advice { super }

      private

      def with_plan_advice(&blk)
        return yield unless plan_advice_value

        klass.with_connection do |conn|
          Execution.with_advice(conn, plan_advice_value.to_s, &blk)
        end
      end

      def exec_main_query(*args, **kwargs, &blk)
        return super unless plan_advice_value

        klass.with_connection do |conn|
          Execution.with_advice(conn, plan_advice_value.to_s) { super(*args, **kwargs, &blk) }
        end
      end
    end
  end
end
