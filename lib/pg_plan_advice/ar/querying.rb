module PgPlanAdvice
  module AR
    module Querying
      def plan_advice(&blk)
        all.plan_advice(&blk)
      end
    end
  end
end
