module PgPlanAdvice
  module AR
    module Execution
      GUC = "pg_plan_advice.advice"
      MIN_SERVER_VERSION = 190_000

      SUPPORT = ObjectSpace::WeakMap.new

      def self.with_advice(connection, advice)
        return yield if advice.nil? || advice.empty?
        return yield unless usable?(connection)

        if connection.transaction_open?
          previous = connection.select_value("SELECT current_setting('#{GUC}', true)")
          apply(connection, advice)

          begin
            yield
          ensure
            restore(connection, previous)
          end
        else
          connection.transaction do
            apply(connection, advice)
            yield
          end
        end
      end

      def self.usable?(connection)
        support = support_for(connection)
        return true if support == :supported

        if PgPlanAdvice.on_unsupported == :raise
          raise UnsupportedDatabaseError, unsupported_message(connection, support)
        end

        false
      end

      def self.support_for(connection)
        return SUPPORT[connection] if SUPPORT.key?(connection)

        support = detect_support(connection)
        warn_unsupported(connection, support)
        SUPPORT[connection] = support
      end

      def self.detect_support(connection)
        return :adapter unless postgresql?(connection)
        return :version if connection.database_version < MIN_SERVER_VERSION
        return :module if connection.select_value("SELECT 1 FROM pg_settings WHERE name = '#{GUC}'").nil?

        :supported
      end

      def self.postgresql?(connection)
        defined?(::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
          connection.is_a?(::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      end

      def self.warn_unsupported(connection, support)
        return if support == :supported || PgPlanAdvice.on_unsupported != :warn

        ::ActiveRecord::Base.logger&.warn("#{unsupported_message(connection, support)}, running queries without advice")
      end

      def self.unsupported_message(connection, support)
        case support
        when :adapter
          "pg_plan_advice requires PostgreSQL, got: #{connection.adapter_name}"
        when :version
          "pg_plan_advice requires PostgreSQL 19 or newer, got: #{server_version(connection.database_version)}"
        when :module
          "pg_plan_advice module is not loaded, load it with shared_preload_libraries"
        end
      end

      def self.server_version(version_num)
        "#{version_num / 10_000}.#{version_num % 10_000}"
      end

      def self.apply(connection, value)
        connection.select_value("SELECT set_config('#{GUC}', #{connection.quote(value)}, true)")
      end

      def self.restore(connection, value)
        apply(connection, value)
      rescue ::ActiveRecord::StatementInvalid
        # ?
      end
    end
  end
end
