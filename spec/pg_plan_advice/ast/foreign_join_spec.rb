# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::ForeignJoin do
  it "has tag FOREIGN_JOIN" do
    expect(described_class.tag).to eq("FOREIGN_JOIN")
  end

  describe ".new" do
    it "accepts targets as keyword or positional argument" do
      targets = [ordered_group(target("a"), target("b")), ordered_group(target("c"), target("d"))]

      expect(described_class.new(targets: targets).targets).to eq(targets)
      expect(described_class.new(targets).targets).to eq(targets)
    end

    it "freezes a copy of the targets" do
      targets = [ordered_group(target("a"), target("b"))]
      node = described_class.new(targets: targets)

      expect(node.targets).to be_frozen
      expect(node.targets).not_to be(targets)
      expect(targets).not_to be_frozen
    end

    it "raises when targets are empty" do
      expect { described_class.new(targets: []) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "FOREIGN_JOIN targets must not be empty")
    end

    it "raises on groups with a single relation" do
      expect { described_class.new(targets: [ordered_group(target("a"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /\AFOREIGN_JOIN targets must contain more than one relation identifier, got: \[.*OrderedGroup/)
    end

    it "raises when any group has a single relation" do
      targets = [ordered_group(target("a"), target("b")), ordered_group(target("c"))]

      expect { described_class.new(targets: targets) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /more than one relation identifier, got: \[.*alias_name="c"/)
    end

    it "raises on nested groups" do
      group = ordered_group(target("a"), ordered_group(target("b"), target("c")))

      expect { described_class.new(targets: [group]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /\AFOREIGN_JOIN OrderedGroup may contain only targets, got: \[.*OrderedGroup/)
    end

    it "raises on plain targets" do
      expect { described_class.new(targets: [target("a")]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /accepts only target, got: \[.*Target/)
    end

    it "raises on unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /accepts only target, got: \[.*UnorderedGroup/)
    end

    it "raises on non-AST items" do
      expect { described_class.new(targets: ["a"]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, 'FOREIGN_JOIN accepts only target, got: ["a"]')
    end

    it "compares by value" do
      node = described_class.new(targets: [ordered_group(target("a"), target("b"))])

      expect(node).to eq(described_class.new(targets: [ordered_group(target("a"), target("b"))]))
      expect(node).not_to eq(described_class.new(targets: [ordered_group(target("a"), target("c"))]))
    end
  end
end
