# frozen_string_literal: true

RSpec.describe PgPlanAdvice::DefaultResolver do
  subject(:resolver) { described_class.new }

  describe "#resolve" do
    it "resolves symbols and strings to targets" do
      expect(resolver.resolve(:a)).to eq(target("a"))
      expect(resolver.resolve("b")).to eq(target("b"))
    end

    it "returns targets unchanged" do
      custom = target("a", occurrence_number: 2, plan_name: "sub")

      expect(resolver.resolve(custom)).to be(custom)
    end

    it "resolves hashes to index targets" do
      expect(resolver.resolve(a: :a_idx, "b" => "s.b_idx"))
        .to eq([index_target("a", "a_idx"), index_target("b", "s.b_idx")])
    end

    it "accepts targets as hash keys" do
      custom = target("a", partition_schema: "s", partition_name: "p")

      expect(resolver.resolve(custom => :a_idx))
        .to eq([PgPlanAdvice::Ast::IndexTarget.new(custom, "a_idx")])
    end

    it "raises on unsupported hash keys" do
      expect { resolver.resolve(1 => :idx) }
        .to raise_error(PgPlanAdvice::InvalidAdviceError, "Invalid advice target: 1")
    end

    it "raises on unsupported items" do
      expect { resolver.resolve(1) }.to raise_error(PgPlanAdvice::InvalidAdviceError, "Invalid advice target: 1")
    end
  end
end
