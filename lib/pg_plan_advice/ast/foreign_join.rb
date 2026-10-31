module PgPlanAdvice
  module Ast
    class ForeignJoin < Node
      accepts OrderedGroup
      advice_name "FOREIGN_JOIN"

      def initialize(targets:)
        super

        single = targets.select { _1.items.one? }
        invalid!("targets must contain more than one relation identifier, got: #{single.inspect}") if single.any?
      end
    end
  end
end
