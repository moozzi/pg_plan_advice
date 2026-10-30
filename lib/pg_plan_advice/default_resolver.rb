module PgPlanAdvice
  class DefaultResolver
    def resolve(item)
      case item
      when Symbol, String then Ast::Target.new(alias_name: item.to_s)
      when Hash
        item.map do |target, index_name|
          Ast::IndexTarget.new(Ast::Target.new(target), index_name)
        end
      else raise InvalidAdviceError, "Invalid advice target: #{item.inspect}"
      end
    end
  end
end
