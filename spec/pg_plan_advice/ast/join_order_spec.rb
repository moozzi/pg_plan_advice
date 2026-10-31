# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::JoinOrder do
  it "has tag JOIN_ORDER" do
    expect(described_class.tag).to eq("JOIN_ORDER")
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
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "JOIN_ORDER targets must not be empty")
    end

    it "accepts nested ordered and unordered groups" do
      targets = [
        target("a"),
        ordered_group(target("b"), ordered_group(target("c"), unordered_group(target("d"), target("e"))))
      ]

      expect(described_class.new(targets: targets).targets).to eq(targets)
    end

    it "raises on empty ordered groups" do
      expect { described_class.new(targets: [target("a"), ordered_group]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "OrderedGroup must not be empty")
    end

    it "accepts unordered groups at the top level" do
      targets = [unordered_group(target("a"), target("b")), target("c")]

      expect(described_class.new(targets: targets).targets).to eq(targets)
    end

    it "raises on ordered groups in unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"), ordered_group(target("b")))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /\AJOIN_ORDER UnorderedGroup may contain only targets, got: \[.*OrderedGroup/)
    end

    it "raises on unordered groups in unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"), unordered_group(target("b")))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        /\AJOIN_ORDER UnorderedGroup may contain only targets, got: \[.*UnorderedGroup/)
    end

    it "raises on groups in unordered groups nested deep in ordered groups" do
      unordered = unordered_group(target("c"), ordered_group(target("d")))
      group = ordered_group(target("a"), ordered_group(target("b"), unordered))

      expect { described_class.new(targets: [group]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, /\AJOIN_ORDER UnorderedGroup may contain only targets/)
    end

    it "raises on non-AST items in unordered groups" do
      expect { described_class.new(targets: [unordered_group(target("a"), "b")]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        'JOIN_ORDER UnorderedGroup may contain only targets, got: ["b"]')
    end

    it "raises on non-AST items in ordered groups" do
      expect { described_class.new(targets: [ordered_group(target("a"), ordered_group(target("b"), "c"))]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        'JOIN_ORDER OrderedGroup may contain only targets and groups, got: ["c"]')
    end

    it "raises on non-AST items" do
      expect { described_class.new(targets: ["a"]) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, 'JOIN_ORDER accepts only target, got: ["a"]')
    end

    it "compares by value" do
      node = described_class.new(targets: [target("a")])

      expect(node).to eq(described_class.new(targets: [target("a")]))
      expect(node).not_to eq(described_class.new(targets: [target("b")]))
    end
  end
end
