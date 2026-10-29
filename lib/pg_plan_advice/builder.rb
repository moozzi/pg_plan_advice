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
    def seq_scan(*targets) = add(Ast::SeqScan, targets)
    def tid_scan(*targets) = add(Ast::TidScan, targets)
    def index_scan(targets) = add_index(Ast::IndexScan, targets)
    def index_only_scan(*targets) = add_index(Ast::IndexOnlyScan, targets)
    def foreign_join(*targets) = add(Ast::ForeignJoin, targets)
    def bitmap_heap_scan(*targets) = add(Ast::BitmapHeapScan, targets)
    def do_not_scan(*targets) = add(Ast::DoNotScan, targets)

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
    def join_order(*targets) = add(Ast::JoinOrder, targets)

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
    def merge_join_materialize(*targets)  = add(Ast::MergeJoinMaterialize, targets)
    def merge_join_plain(*targets)        = add(Ast::MergeJoinPlain, targets)
    def nested_loop_materialize(*targets) = add(Ast::NestedLoopMaterialize, targets)
    def nested_loop_memoize(*targets)     = add(Ast::NestedLoopMemoize, targets)
    def nested_loop_plain(*targets)       = add(Ast::NestedLoopPlain, targets)
    def hash_join(*targets)               = add(Ast::HashJoin, targets)

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
    def partitionwise(*targets) = add(Ast::Partitionwise, targets)

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
    def semijoin_unique(*targets)     = add(Ast::SemijoinUnique, targets)
    def semijoin_non_unique(*targets) = add(Ast::SemijoinNonUnique, targets)

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
    def gather(*targets)       = add(Asl::Gather, targets)
    def gather_merge(*targets) = add(Ast::GatherMerge, targets)
    def no_gather(*targets)    = add(Ast::NoGather, targets)

    def result = Ast::AdviceSet.new(@items)

    def ordered(*targets)   = Ast::OrderedGroup.new(targets.map { |target| normalize(target) })
    def unordered(*targets) = Ast::UnorderedGroup.new(targets.map { |target| normalize(target) })

    private

    def add(node_class, targets)
      @items << node_class.new(targets.map { |target| normalize(target) })
      self
    end

    def add_index(node_class, targets)
      raise "invalid argument for index_scan/index_only_scan in #{targets}" if !targets.is_a?(Hash)

      @items << node_class.new(normalize(targets))
      self
    end

    def normalize(item)
      case item
      when Ast::Target, Ast::OrderedGroup, Ast::UnorderedGroup
        item
      when Symbol, String
        Ast::Target.new(item)
      when Hash
        item.map do |target, index_name|
          Ast::IndexTarget.new(target, index_name)
        end
      else
        raise ArgumentError, "invalid item"
      end
    end
  end

  def self.build(&block)
    builder = Builder.new
    builder.instance_exec(&block)
    builder.result
  end
end
