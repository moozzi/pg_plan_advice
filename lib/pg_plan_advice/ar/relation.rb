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

      private

      def exec_main_query(*args, **kwargs, &blk)
        return super unless plan_advice_value

        klass.with_connection do |conn|
          Execution.with_advice(conn, plan_advice_value.to_s) { super(*args, **kwargs, &blk) }
        end
      end
    end
  end
end
