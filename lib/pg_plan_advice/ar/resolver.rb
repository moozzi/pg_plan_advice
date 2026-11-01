module PgPlanAdvice
  module AR
    class Resolver
      def initialize(model)
        @model = model
      end

      def resolve(item)
        name = case item
               when Class  then item.table_name
               when Symbol then @model.reflect_on_association(item)&.klass&.table_name || item.to_s
               when String then item
               else raise InvalidAdviceError, "Invalid advice target: #{item.inspect}"
               end

        Ast::Target.new(alias_name: name)
      end
    end
  end
end
