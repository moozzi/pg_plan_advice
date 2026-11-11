# frozen_string_literal: true

RSpec.describe PgPlanAdvice::Ast::Target do
  describe ".new" do
    it "requires only alias_name" do
      expect(described_class.new(alias_name: "a")).to have_attributes(
        alias_name: "a", occurrence_number: nil, partition_schema: nil, partition_name: nil, plan_name: nil
      )
    end

    it "accepts all attributes" do
      target = described_class.new(alias_name: "a", occurrence_number: 2, partition_schema: "s",
                                   partition_name: "p", plan_name: "sub")

      expect(target.to_s).to eq("a#2/s.p@sub")
    end

    it "raises when only partition_name is given" do
      expect { described_class.new(alias_name: "a", partition_name: "p") }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        "Target partition_schema and partition_name must be given together")
    end

    it "raises when only partition_schema is given" do
      expect { described_class.new(alias_name: "a", partition_schema: "s") }
        .to raise_error(PgPlanAdvice::InvalidAdviceError,
                        "Target partition_schema and partition_name must be given together")
    end

    it "accepts positive integer occurrence numbers" do
      expect(described_class.new(alias_name: "a", occurrence_number: 1).occurrence_number).to eq(1)
      expect(described_class.new(alias_name: "a", occurrence_number: 3).occurrence_number).to eq(3)
    end

    it "quotes identifiers that need quoting" do
      target = described_class.new(alias_name: "A", partition_schema: "My Schema", partition_name: "p-1",
                                   plan_name: "Sub")

      expect(target.to_s).to eq('"A"/"My Schema"."p-1"@"Sub"')
    end

    [0, -1, "2", 1.5].each do |value|
      it "raises on occurrence number #{value.inspect}" do
        expect { described_class.new(alias_name: "a", occurrence_number: value) }
          .to raise_error(PgPlanAdvice::InvalidAdviceError,
                          "Target occurrence_number must be a positive integer, got: #{value.inspect}")
      end
    end
  end
end
