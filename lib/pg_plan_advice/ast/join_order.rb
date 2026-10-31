module PgPlanAdvice
  module Ast
    class JoinOrder < Node
      accepts Target, OrderedGroup, UnorderedGroup, allow_nesting: true
      advice_name "JOIN_ORDER"
    end
  end
end
