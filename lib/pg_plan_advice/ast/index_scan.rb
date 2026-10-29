module PgPlanAdvice
  module Ast
    class IndexScan < Node
      def initialize(targets:)
        raise InvalidAdviceError, "#{advice_name} targets must not be empty" if targets.empty?

        invalid = targets.reject { |target| target.is_a?(IndexTarget) }
        unless invalid.empty?
          raise InvalidAdviceError,
                "#{advice_name} accepts only target/index_name pairs, got: #{invalid.inspect}"
        end

        super(targets: targets.dup.freeze)
      end

      def self.advice_name
        "INDEX_SCAN"
      end
    end
  end
end
