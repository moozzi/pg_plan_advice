# frozen_string_literal: true

require "active_record"

require_relative "pg_plan_advice/version"
require_relative "pg_plan_advice/builder"
require_relative "pg_plan_advice/ar/execution"
require_relative "pg_plan_advice/ar/querying"
require_relative "pg_plan_advice/ar/relation"
require_relative "pg_plan_advice/ar/resolver"

module PgPlanAdvice
  class Error < StandardError; end
  class InvalidAdviceError < Error; end
  class UnsupportedDatabaseError < Error; end

  ON_UNSUPPORTED = %i[raise warn ignore].freeze

  class << self
    attr_reader :on_unsupported

    def on_unsupported=(value)
      unless ON_UNSUPPORTED.include?(value)
        raise ArgumentError, "on_unsupported must be one of #{ON_UNSUPPORTED.inspect}, got: #{value.inspect}"
      end

      @on_unsupported = value
    end
  end

  self.on_unsupported = :raise
end

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Relation.prepend(PgPlanAdvice::AR::Relation)
  extend PgPlanAdvice::AR::Querying
end
