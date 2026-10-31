module PgPlanAdvice
  module Ast
    class Node < Data.define(:targets)
      class << self
        attr_reader :tag

        def accepts(*matchers, allow_nesting: false)
          @accepted = matchers.freeze
          @allow_nesting = allow_nesting
        end

        def advice_name(tag)
          @tag = tag
        end

        def accepts?(item)
          @accepted.any? { _1 === item }
        end

        def nesting_in?(group)
          @allow_nesting && group.is_a?(OrderedGroup)
        end
      end

      def initialize(targets:)
        invalid!("targets must not be empty") if targets.empty?

        unexpected = targets.reject { self.class.accepts?(_1) }
        invalid!("accepts only target, got: #{unexpected.inspect}") if unexpected.any?

        validate_groups!(targets)

        super(targets: targets.dup.freeze)
      end

      private

      def validate_groups!(items)
        items.select { group?(_1) }.each do |group|
          nesting = self.class.nesting_in?(group)
          unexpected = group.items.reject { _1.is_a?(Target) || (nesting && group?(_1)) }
          invalid_group!(group, nesting, unexpected) if unexpected.any?

          validate_groups!(group.items)
        end
      end

      def invalid_group!(group, nesting, unexpected)
        allowed = nesting ? "targets and groups" : "targets"
        invalid!("#{group.class.name.split("::").last} may contain only #{allowed}, got: #{unexpected.inspect}")
      end

      def group?(item)
        item.is_a?(OrderedGroup) || item.is_a?(UnorderedGroup)
      end

      def invalid!(message)
        raise InvalidAdviceError, "#{self.class.tag} #{message}"
      end
    end
  end
end
