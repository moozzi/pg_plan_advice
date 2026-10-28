require_relative "./ast"

module PgPlanAdvice
  class Builder
    attr_accessor :items # to remove?

    def initialize
      @items = []
    end

    #
    # Scan method advice
    #
    # SEQ_SCAN(target [ ... ])
    # TID_SCAN(target [ ... ])
    # INDEX_SCAN(target index_name [ ... ])
    # INDEX_ONLY_SCAN(target index_name [ ... ])
    # FOREIGN_JOIN((target [ ... ]) [ ... ])
    # BITMAP_HEAP_SCAN(target [ ... ])
    # DO_NOT_SCAN(target [ ... ])
    #

    #
    # Join order advice
    #
    # JOIN_ORDER(join_order_item [ ... ])
    #
    # where join_order_item is:
    #
    # advice_target |
    # ( join_order_item [ ... ] ) |
    # { join_order_item [ ... ] }
    #

    #
    # Join method advice
    #
    # join_method_name(join_method_item [ ... ])
    #
    # where join_method_name is:
    #
    # { MERGE_JOIN_MATERIALIZE | MERGE_JOIN_PLAIN | NESTED_LOOP_MATERIALIZE | NESTED_LOOP_MEMOIZE | NESTED_LOOP_PLAIN | HASH_JOIN }
    #
    # and join_method_item is:
    #
    # { advice_target |
    # ( advice_target [ ... ] ) }
    #

    def merge_join_materialize(*targets)  = add(Ast::MergeJoinMaterialize.new(resolve(targets)))
    def merge_join_plain(*targets)        = add(Ast::MergeJoinPlain.new(resolve(targets)))
    def nested_loop_materialize(*targets) = add(Ast::NestedLoopMaterialize.new(resolve(targets)))
    def nested_loop_memoize(*targets)     = add(Ast::NestedLoopMemoize.new(resolve(targets)))
    def nested_loop_plain(*targets)       = add(Ast::NestedLoopPlain.new(resolve(targets)))
    def hash_join(*targets)               = add(Ast::HashJoin.new(resolve(targets)))

    #
    # Partitionwise advice
    #
    # PARTITIONWISE(partitionwise_item [ ... ])
    #
    # where partitionwise_item is:
    #
    # { advice_target |
    # ( advice_target [ ... ] ) }
    #

    #
    # Semijoin uniqueness advice
    #
    # SEMIJOIN_UNIQUE(sj_unique_item [ ... ])
    # SEMIJOIN_NON_UNIQUE(sj_unique_item [ ... ])
    #
    # where sj_unique_item is:
    #
    # { advice_target |
    # ( advice_target [ ... ] ) }
    #

    #
    # Parallel query advice
    #
    # GATHER(gather_item [ ... ])
    # GATHER_MERGE(gather_item [ ... ])
    # NO_GATHER(advice_target [ ... ])
    #
    # where gather_item is:
    #
    # { advice_target |
    # ( advice_target [ ... ] ) }
    #

    def result = Ast::AdviceSet.new(@items)

    private

    def add(node)
      @items << node
      self
    end

    def resolve(targets)
      targets.map do |target|
        case target
        when Symbol then target.to_s
        when Array  then "(#{resolve(target)})"
        else
          raise "invalid advice_target"
        end
      end.join(" ")
    end
  end

  def self.build(&block)
    builder = Builder.new
    builder.instance_exec(&block)
    builder.result
  end
end
