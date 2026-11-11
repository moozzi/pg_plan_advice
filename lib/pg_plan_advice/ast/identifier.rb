module PgPlanAdvice
  module Ast
    module Identifier
      def self.quote(name)
        name = name.to_s
        return name if name.match?(/\A[a-z_][a-z0-9_$]*\z/)

        "\"#{name.gsub('"', '""')}\""
      end
    end
  end
end
