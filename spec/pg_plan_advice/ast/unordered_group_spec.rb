# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::UnorderedGroup do
  describe ".new" do
    it "accepts items as keyword or positional argument" do
      items = [target("a"), target("b")]

      expect(described_class.new(items: items).items).to eq(items)
      expect(described_class.new(items).items).to eq(items)
    end

    it "raises when items are empty" do
      expect { described_class.new(items: []) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "UnorderedGroup must not be empty")
    end
  end
end
