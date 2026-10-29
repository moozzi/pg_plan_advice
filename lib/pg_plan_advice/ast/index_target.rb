module PgPlanAdvice
  module Ast
    class IndexTarget < Data.define(:target, :index_name)
      def initialize(target:, index_name:)
        unless target.is_a?(Target)
          raise InvalidAdviceError, "Index advice target must be a single target, got #{target.inspect}"
        end

        index_name = index_name.to_s
        raise InvalidAdviceError, "Index name must not be empty" if index_name.empty?

        super(target:, index_name: index_name.freeze)
      end

      def to_s
        "#{target} #{index_name}"
      end
    end
  end
end
