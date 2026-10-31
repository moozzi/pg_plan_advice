# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::SemijoinNonUnique do
  it "has advice_name SEMIJOIN_NON_UNIQUE" do
    expect(described_class.advice_name).to eq("SEMIJOIN_NON_UNIQUE")
    expect(described_class.new(targets: [target("a")]).advice_name).to eq("SEMIJOIN_NON_UNIQUE")
  end

  describe ".new" do
    it "accepts targets as keyword or positional argument" do
      targets = [target("a"), target("b")]

      expect(described_class.new(targets: targets).targets).to eq(targets)
      expect(described_class.new(targets).targets).to eq(targets)
    end

    it "freezes a copy of the targets" do
      targets = [target("a")]
      node = described_class.new(targets: targets)

      expect(node.targets).to be_frozen
      expect(node.targets).not_to be(targets)
      expect(targets).not_to be_frozen
    end

    it "raises when targets are empty" do
      expect { described_class.new(targets: []) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "SEMIJOIN_NON_UNIQUE targets must not be empty")
    end

    it "accepts flat ordered groups" do
      targets = [target("a"), ordered_group(target("b"), target("c"))]

      expect(described_class.new(targets: targets).targets).to eq(targets)
    end

    it "raises on nested ordered groups" do
      expect { described_class.new(targets: [ordered_group(target("a"), ordered_group(target("b")))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "SEMIJOIN_NON_UNIQUE: does not allow nesting")
    end

    it "raises on unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\ASEMIJOIN_NON_UNIQUE: invalid target: .*UnorderedGroup/)
    end

    it "raises on non-AST items" do
      expect { described_class.new(targets: ["a"]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, 'SEMIJOIN_NON_UNIQUE: invalid target: "a"')
    end

    it "compares by value" do
      node = described_class.new(targets: [target("a")])

      expect(node).to eq(described_class.new(targets: [target("a")]))
      expect(node).not_to eq(described_class.new(targets: [target("b")]))
    end
  end
end
