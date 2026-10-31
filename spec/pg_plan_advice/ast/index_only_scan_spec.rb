# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::IndexOnlyScan do
  it "has tag INDEX_ONLY_SCAN" do
    expect(described_class.tag).to eq("INDEX_ONLY_SCAN")
  end

  describe ".new" do
    it "accepts targets as keyword or positional argument" do
      targets = [index_target("a", "a_idx"), index_target("b", "b_idx")]

      expect(described_class.new(targets: targets).targets).to eq(targets)
      expect(described_class.new(targets).targets).to eq(targets)
    end

    it "freezes a copy of the targets" do
      targets = [index_target("a", "a_idx")]
      node = described_class.new(targets: targets)

      expect(node.targets).to be_frozen
      expect(node.targets).not_to be(targets)
      expect(targets).not_to be_frozen
    end

    it "raises when targets are empty" do
      expect { described_class.new(targets: []) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "INDEX_ONLY_SCAN targets must not be empty")
    end

    it "raises on plain targets" do
      expect { described_class.new(targets: [target("a")]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /accepts only target, got: \[.*Target/)
    end

    it "raises on groups" do
      expect { described_class.new(targets: [ordered_group(target("a"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /accepts only target, got: \[.*OrderedGroup/)
    end

    it "raises on non-AST items" do
      expect { described_class.new(targets: ["a"]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        'INDEX_ONLY_SCAN accepts only target, got: ["a"]')
    end

    it "compares by value" do
      node = described_class.new(targets: [index_target("a", "a_idx")])

      expect(node).to eq(described_class.new(targets: [index_target("a", "a_idx")]))
      expect(node).not_to eq(described_class.new(targets: [index_target("a", "other_idx")]))
    end
  end
end
