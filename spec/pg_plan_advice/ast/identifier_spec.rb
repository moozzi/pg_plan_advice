RSpec.describe PgPlanAdvice::Ast::Identifier do
  describe ".quote" do
    it "leaves lowercase identifiers unquoted" do
      expect(described_class.quote("users")).to eq("users")
      expect(described_class.quote("_tmp$1")).to eq("_tmp$1")
      expect(described_class.quote(:posts_comments)).to eq("posts_comments")
    end

    it "quotes identifiers with uppercase letters" do
      expect(described_class.quote("Users")).to eq('"Users"')
    end

    it "quotes identifiers that don't start with a letter or underscore" do
      expect(described_class.quote("1abc")).to eq('"1abc"')
      expect(described_class.quote("$abc")).to eq('"$abc"')
    end

    it "quotes identifiers with special characters" do
      expect(described_class.quote("*VALUES*")).to eq('"*VALUES*"')
      expect(described_class.quote("my table")).to eq('"my table"')
      expect(described_class.quote("a.b")).to eq('"a.b"')
    end

    it "doubles quotes inside identifiers" do
      expect(described_class.quote('a"b')).to eq('"a""b"')
    end
  end
end
