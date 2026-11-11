RSpec.describe PgPlanAdvice::Ast::IndexTarget do
  describe "#to_s" do
    it "serializes target and index name" do
      expect(index_target("a", "a_idx").to_s).to eq("a a_idx")
      expect(index_target("a", "public.a_idx").to_s).to eq("a public.a_idx")
    end

    it "quotes schema and index name separately" do
      expect(index_target("A", "My Schema.A_idx").to_s).to eq('"A" "My Schema"."A_idx"')
    end

    it "keeps dots after the schema in the index name" do
      expect(index_target("a", "s.a.idx").to_s).to eq('a s."a.idx"')
    end
  end
end
