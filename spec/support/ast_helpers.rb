# frozen_string_literal: true

module AstHelpers
  def target(name, **options) = PgPlanAdvice::Ast::Target.new(alias_name: name, **options)
  def index_target(name, index_name) = PgPlanAdvice::Ast::IndexTarget.new(target(name), index_name)
  def ordered_group(*items) = PgPlanAdvice::Ast::OrderedGroup.new(items)
  def unordered_group(*items) = PgPlanAdvice::Ast::UnorderedGroup.new(items)
end
