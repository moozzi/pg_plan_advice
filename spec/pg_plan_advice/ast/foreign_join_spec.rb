# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::ForeignJoin do
  it "has advice_name FOREIGN_JOIN" do
    expect(described_class.advice_name).to eq("FOREIGN_JOIN")
    expect(described_class.new(targets: [ordered_group(target("a"))]).advice_name).to eq("FOREIGN_JOIN")
  end

  describe ".new" do
    it "accepts targets as keyword or positional argument" do
      targets = [ordered_group(target("a"), target("b")), ordered_group(target("c"))]

      expect(described_class.new(targets: targets).targets).to eq(targets)
      expect(described_class.new(targets).targets).to eq(targets)
    end

    it "freezes a copy of the targets" do
      targets = [ordered_group(target("a"))]
      node = described_class.new(targets: targets)

      expect(node.targets).to be_frozen
      expect(node.targets).not_to be(targets)
      expect(targets).not_to be_frozen
    end

    it "raises when targets are empty" do
      expect { described_class.new(targets: []) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "FOREIGN_JOIN targets must not be empty")
    end

    it "raises on plain targets" do
      expect { described_class.new(targets: [target("a")]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /accepts only targets, got: \[.*Target/)
    end

    it "raises on unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /accepts only targets, got: \[.*UnorderedGroup/)
    end

    it "raises on non-AST items" do
      expect { described_class.new(targets: ["a"]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, 'FOREIGN_JOIN accepts only targets, got: ["a"]')
    end

    it "compares by value" do
      node = described_class.new(targets: [ordered_group(target("a"))])

      expect(node).to eq(described_class.new(targets: [ordered_group(target("a"))]))
      expect(node).not_to eq(described_class.new(targets: [ordered_group(target("b"))]))
    end
  end
end
