RSpec.describe "PostgreSQL pg_plan_advice compatibility" do
  def advice(&) = PgPlanAdvice.build(&).to_s

  describe "scan.sql" do
    it "builds scan advice" do
      expect(advice { seq_scan :scan_table }).to eq("SEQ_SCAN(scan_table)")
      expect(advice { tid_scan :scan_table }).to eq("TID_SCAN(scan_table)")
      expect(advice { bitmap_heap_scan :scan_table }).to eq("BITMAP_HEAP_SCAN(scan_table)")
      expect(advice { do_not_scan :scan_table }).to eq("DO_NOT_SCAN(scan_table)")
    end

    it "builds index advice" do
      expect(advice { index_scan scan_table: :scan_table_pkey }).to eq("INDEX_SCAN(scan_table scan_table_pkey)")
      expect(advice { index_scan scan_table: "public.scan_table_pkey" })
        .to eq("INDEX_SCAN(scan_table public.scan_table_pkey)")
      expect(advice { index_only_scan scan_table: :scan_table_pkey })
        .to eq("INDEX_ONLY_SCAN(scan_table scan_table_pkey)")
    end

    it "builds advice with occurrence numbers and plan names" do
      second = target("s", occurrence_number: 2)
      in_subquery = target("s", plan_name: "unnamed_subquery")

      expect(advice { seq_scan second }).to eq("SEQ_SCAN(s#2)")
      expect(advice { seq_scan in_subquery }).to eq("SEQ_SCAN(s@unnamed_subquery)")
      expect(advice { seq_scan(:s).seq_scan(second) }).to eq("SEQ_SCAN(s) SEQ_SCAN(s#2)")
    end
  end

  describe "alternatives.sql" do
    it "builds advice for subplans" do
      first = target("alt_minmax", plan_name: "minmax_1")
      second = target("alt_minmax", plan_name: "minmax_2")

      expect(advice { do_not_scan(first).do_not_scan(second) })
        .to eq("DO_NOT_SCAN(alt_minmax@minmax_1) DO_NOT_SCAN(alt_minmax@minmax_2)")
    end
  end

  describe "join_order.sql" do
    it "builds plain join orders" do
      expect(advice { join_order :f, :d1, :d2 }).to eq("JOIN_ORDER(f d1 d2)")
      expect(advice { join_order(:f).join_order(:d1) }).to eq("JOIN_ORDER(f) JOIN_ORDER(d1)")
    end

    it "builds join orders with ordered groups" do
      expect(advice { join_order ordered(:f, :d1, :d2) }).to eq("JOIN_ORDER((f d1 d2))")
      expect(advice { join_order ordered(:f, :d1), :d2 }).to eq("JOIN_ORDER((f d1) d2)")
      expect(advice { join_order :f, ordered(:d1), :d2 }).to eq("JOIN_ORDER(f (d1) d2)")
    end

    it "builds join orders with unordered groups" do
      expect(advice { join_order unordered(:f, :d1, :d2) }).to eq("JOIN_ORDER({f d1 d2})")
      expect(advice { join_order unordered(:f, :d1), :d2 }).to eq("JOIN_ORDER({f d1} d2)")
      expect(advice { join_order :f, unordered(:d1, :d2) }).to eq("JOIN_ORDER(f {d1 d2})")
    end

    it "builds join orders with nested groups" do
      expect(advice { join_order :f, ordered(unordered(:d1, :d2)) }).to eq("JOIN_ORDER(f ({d1 d2}))")
    end

    it "builds join orders with partitions" do
      partition = target("f", partition_schema: "public", partition_name: "d1")

      expect(advice { join_order partition, ordered(:d1, :d2) }).to eq("JOIN_ORDER(f/public.d1 (d1 d2))")
    end

    it "combines join order with other advice" do
      expect(advice { join_order(:d1).hash_join(:d1) }).to eq("JOIN_ORDER(d1) HASH_JOIN(d1)")
    end
  end

  describe "join_strategy.sql" do
    it "builds join method advice" do
      expect(advice { hash_join :f }).to eq("HASH_JOIN(f)")
      expect(advice { merge_join_materialize :f }).to eq("MERGE_JOIN_MATERIALIZE(f)")
      expect(advice { merge_join_plain :f }).to eq("MERGE_JOIN_PLAIN(f)")
      expect(advice { nested_loop_materialize :f }).to eq("NESTED_LOOP_MATERIALIZE(f)")
      expect(advice { nested_loop_memoize :f }).to eq("NESTED_LOOP_MEMOIZE(f)")
      expect(advice { nested_loop_plain :f, :d }).to eq("NESTED_LOOP_PLAIN(f d)")
      expect(advice { nested_loop_plain(:f).nested_loop_materialize(:f) })
        .to eq("NESTED_LOOP_PLAIN(f) NESTED_LOOP_MATERIALIZE(f)")
    end

    it "builds foreign join advice" do
      expect(advice { foreign_join ordered(:f, :d) }).to eq("FOREIGN_JOIN((f d))")
    end
  end

  describe "partitionwise.sql" do
    it "builds partitionwise advice" do
      expect(advice { partitionwise :pt1, :pt2, :pt3 }).to eq("PARTITIONWISE(pt1 pt2 pt3)")
      expect(advice { partitionwise ordered(:pt1, :pt2), :pt3 }).to eq("PARTITIONWISE((pt1 pt2) pt3)")
      expect(advice { partitionwise ordered(:pt1, :pt2), ordered(:pt1, :pt3) })
        .to eq("PARTITIONWISE((pt1 pt2) (pt1 pt3))")
      expect(advice { partitionwise(ordered(:pt1, :pt2)).join_order(unordered(:pt1, :pt2), :pt3) })
        .to eq("PARTITIONWISE((pt1 pt2)) JOIN_ORDER({pt1 pt2} pt3)")
    end

    it "builds join orders over partitions" do
      pt3a = target("pt3", partition_schema: "public", partition_name: "pt3a")
      pt2a = target("pt2", partition_schema: "public", partition_name: "pt2a")
      pt1a = target("pt1", partition_schema: "public", partition_name: "pt1a")

      expect(advice { join_order pt3a, pt2a, pt1a })
        .to eq("JOIN_ORDER(pt3/public.pt3a pt2/public.pt2a pt1/public.pt1a)")
    end
  end

  describe "semijoin.sql" do
    it "builds semijoin advice" do
      expect(advice { semijoin_unique :sj_narrow }).to eq("SEMIJOIN_UNIQUE(sj_narrow)")
      expect(advice { semijoin_non_unique :sj_narrow }).to eq("SEMIJOIN_NON_UNIQUE(sj_narrow)")
      expect(advice { semijoin_unique(:sj_narrow).join_order(:sj_narrow) })
        .to eq("SEMIJOIN_UNIQUE(sj_narrow) JOIN_ORDER(sj_narrow)")
    end

    it "quotes identifiers that need quoting" do
      expect(advice { semijoin_unique "*VALUES*" }).to eq('SEMIJOIN_UNIQUE("*VALUES*")')
    end
  end

  describe "gather.sql" do
    it "builds gather advice" do
      expect(advice { gather :f, :d }).to eq("GATHER(f d)")
      expect(advice { gather ordered(:f, :d) }).to eq("GATHER((f d))")
      expect(advice { gather(:d).no_gather(:f) }).to eq("GATHER(d) NO_GATHER(f)")
      expect(advice { gather_merge ordered(:f, :d) }).to eq("GATHER_MERGE((f d))")
      expect(advice { gather_merge(:f).no_gather(:d) }).to eq("GATHER_MERGE(f) NO_GATHER(d)")
    end

    it "builds gather advice with partitions and plan names" do
      partition = target("d", partition_schema: "d", partition_name: "d")
      in_x = target("gt_fact", plan_name: "x")
      in_y = target("gt_fact", plan_name: "y")
      second = target("gt_fact", occurrence_number: 2)

      expect(advice { gather ordered(:d, partition) }).to eq("GATHER((d d/d.d))")
      expect(advice { no_gather :s, in_x, in_y }).to eq("NO_GATHER(s gt_fact@x gt_fact@y)")
      expect(advice { gather(:unnamed_subquery).no_gather(:gt_fact, second) })
        .to eq("GATHER(unnamed_subquery) NO_GATHER(gt_fact gt_fact#2)")
    end
  end

  describe "syntax.sql" do
    it "accepts tag keywords as identifiers" do
      in_seq_scan = target("t", plan_name: "seq_scan")
      partition = target("t", partition_schema: "public", partition_name: "hash_join")

      expect(advice { seq_scan :hash_join }).to eq("SEQ_SCAN(hash_join)")
      expect(advice { seq_scan :join_order }).to eq("SEQ_SCAN(join_order)")
      expect(advice { seq_scan in_seq_scan }).to eq("SEQ_SCAN(t@seq_scan)")
      expect(advice { seq_scan partition }).to eq("SEQ_SCAN(t/public.hash_join)")
    end

    it "builds a full relation identifier" do
      full = target("x", occurrence_number: 2, partition_schema: "y", partition_name: "z", plan_name: "t")

      expect(advice { seq_scan full }).to eq("SEQ_SCAN(x#2/y.z@t)")
    end

    it "rejects advice PostgreSQL can't parse" do
      expect { advice { join_order } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "JOIN_ORDER targets must not be empty")
      expect { advice { seq_scan ordered(:x) } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\ASEQ_SCAN accepts only target, got: \[.*OrderedGroup/)
      expect { advice { do_not_scan ordered(:x) } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\ADO_NOT_SCAN accepts only target, got: \[.*OrderedGroup/)
      expect { advice { gather ordered(ordered(:x)) } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\AGATHER OrderedGroup may contain only targets, got: /)
      expect { advice { join_order :a, ordered(unordered) } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "UnorderedGroup must not be empty")
    end

    it "rejects foreign joins with a single relation identifier" do
      expect { advice { foreign_join :a } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\AFOREIGN_JOIN accepts only target, got: \[.*Target/)
      expect { advice { foreign_join ordered(:a) } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /\AFOREIGN_JOIN targets must contain more than one relation identifier, got: /)
    end

    it "rejects invalid relation identifiers" do
      expect { advice { seq_scan "" } }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "Target alias_name can't be empty")
      expect { target("x", partition_name: "y") }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        "Target partition_schema and partition_name must be given together")
    end
  end
end
