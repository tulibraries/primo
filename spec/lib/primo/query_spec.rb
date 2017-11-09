# frozen_string_literal: true

require "spec_helper"

describe "#{Primo::Pnxs::Query} parameter validation"  do
  #{{{2 params
  context "Initialize with no arguments" do
    let(:query) { Primo::Pnxs::Query.new }
    it "raises an argument error" do
      expect { query }.to raise_error(ArgumentError)
    end
  end

  context "Initialize with empty parameters" do
    let(:query) { Primo::Pnxs::Query.new({}) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  #{{{2 :field
  context ":field parameter is missing" do
    let(:query) { Primo::Pnxs::Query.new(
      precision: "contains",
      value: "foo"
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":field parameter is not known" do
    let(:query) { Primo::Pnxs::Query.new(
      precision: :contains,
      field: :foo,
      value: "bar"
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":field parameter is known" do
    let(:query) { Primo::Pnxs::Query.new(
      precision: :exact,
      field: :facet_local23,
      value: "bar"
    ) }
    it "does not raise an error" do
      expect { query }.to_not raise_error
    end
  end

  #{{{2 :operator
  context ":operator parameter is not known." do
    let(:query) { Primo::Pnxs::Query.new(
      precision: :exact,
      field: :facet_local23,
      value: "bar",
      operator: :FOO
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":operator parameter is known" do
    let(:query) { Primo::Pnxs::Query.new(
      precision: :exact,
      field: :facet_local23,
      value: "bar",
      operator: :AND
    ) }
    it "does not raise an error" do
      expect { query }.not_to raise_error
    end
  end

  #{{{2 :precision
  context ":precision parameter is missing" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :any,
      value: "foo",
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":precision parameter is not known" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :any,
      value: "foo",
      precision: :foo,
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":precision parameter is known" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :any,
      value: "foo",
      precision: :contains,
    ) }
    it "does not raise error" do
      expect { query }.to_not raise_error
    end
  end

  context ":precision :exact not used with a facet field" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :facet_local1,
      value: "foo",
      precision: :begins_with,
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end


  #{{{2 :value
  context ":value parameter is missing" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :any,
      precision: :contains,
    ) }
    it "raises a query" do
      expect { query }.to raise_error(Primo::Pnxs::Query::QueryError)
    end
  end

  context ":value including commas" do
    let(:query) { Primo::Pnxs::Query.new(
      field: :any,
      precision: :contains,
      value: "A,B,C",
    ) }

    it "replaces commas with spaces" do
      expect("#{query}").to include("A B C")
    end
  end
end
