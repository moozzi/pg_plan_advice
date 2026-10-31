module PgPlanAdvice
  module Ast
    class NoGather < Node
      def initialize(targets:)
        raise InvalidAdviceError, "#{advice_name} targets must not be empty" if targets.empty?

        invalid = targets.reject { |target| target.is_a?(Target) }
        unless invalid.empty?
          raise InvalidAdviceError,
                "#{advice_name} accepts only target, got: #{invalid.inspect}"
        end

        super(targets: targets.dup.freeze)
      end

      def self.advice_name
        "NO_GATHER"
      end
    end
  end
end
