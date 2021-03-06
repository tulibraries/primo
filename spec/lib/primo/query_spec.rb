# frozen_string_literal: true

require "spec_helper"

describe "#{Primo::Search::Query} simple query"  do
  context "pass valid parameters with no logic operator" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        "field" => :facet_local23,
        value: "bar",
      ) }
    it "transforms to an expected string" do
      expect(query.to_s).to eq("facet_local23,exact,bar,AND")
    end
  end

  context "pass valid parameters with logic operator" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        "precision" => :exact,
        "field" =>  :facet_local23,
        "value" => "bar",
        "operator" => :OR,
      ) }
    it "transforms to an expected string" do
      expect(query.to_s).to eq("facet_local23,exact,bar,OR")
    end
  end
end

describe "#{Primo::Search::Query}#and"  do
  context "add nil as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { nil }
    it "raises a query error" do
      expect { query.and(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add an invalid query as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :facet_local23,
      value: "bar"
    } }
    it "raises a query error" do
      expect { query.and(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add a valid query as a second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "transforms to an expected string" do
      expect(query.and(query_foo).to_s).to eq("facet_local23,exact,bar,AND;title,contains,bar,AND")
    end
  end

  context "add a valid query to query that contains OR operator" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
        operator: :OR,
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the OR operator" do
      expect(query.and(query_foo).to_s).to eq("facet_local23,exact,bar,AND;title,contains,bar,AND")
    end
  end

  context "add a valid query to query with default OR operator" do
    let(:query) {
      Primo.configure { |c| c.operator = :OR }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the default OR operator" do
      expect(query.and(query_foo).to_s).to eq("facet_local23,exact,bar,AND;title,contains,bar,OR")
    end
  end
end

describe "#{Primo::Search::Query}#or"  do
  context "add nil as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { nil }
    it "raises a query error" do
      expect { query.or(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add an invalid query as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :facet_local23,
      value: "bar"
    } }
    it "raises a query error" do
      expect { query.or(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add a valid query as a second query" do
    let(:query) {
      Primo.configure { |c| c.operator = :AND }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "transforms to an expected string" do
      expect(query.or(query_foo).to_s).to eq("facet_local23,exact,bar,OR;title,contains,bar,AND")
    end
  end

  context "add a valid query to query that contains AND operator" do
    let(:query) {
      Primo.configure { |c| c.operator = :AND }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
        operator: :AND,
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the AND operator" do
      expect(query.or(query_foo).to_s).to eq("facet_local23,exact,bar,OR;title,contains,bar,AND")
    end
  end

  context "add a valid query to query with default NOT operator" do
    let(:query) {
      Primo.configure { |c| c.operator = :NOT }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the default NOT operator" do
      expect(query.or(query_foo).to_s).to eq("facet_local23,exact,bar,OR;title,contains,bar,NOT")
    end
  end
end

describe "#{Primo::Search::Query}#not"  do
  context "add nil as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { nil }
    it "raises a query error" do
      expect { query.not(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add an invalid query as the second query" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :facet_local23,
      value: "bar"
    } }
    it "raises a query error" do
      expect { query.not(query_foo) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "add a valid query as a second query" do
    let(:query) {
      Primo.configure { |c| c.operator = :AND }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "transforms to an expected string" do
      expect(query.not(query_foo).to_s).to eq("facet_local23,exact,bar,NOT;title,contains,bar,AND")
    end
  end

  context "add a valid query to query that contains AND operator" do
    let(:query) {
      Primo.configure { |c| c.operator = :AND }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
        operator: :AND,
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the AND operator" do
      expect(query.not(query_foo).to_s).to eq("facet_local23,exact,bar,NOT;title,contains,bar,AND")
    end
  end

  context "add a valid query to query with default NOT operator" do
    let(:query) {
      Primo.configure { |c| c.operator = :NOT }
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:query_foo) { {
      precision: :contains,
      field: :title,
      value: "bar"
    } }
    it "overrides the default NOT operator" do
      expect(query.not(query_foo).to_s).to eq("facet_local23,exact,bar,NOT;title,contains,bar,NOT")
    end
  end
end

describe "#{Primo::Search::Query}::build" do
  context "pass nil as an argument" do
    it "raises an error" do
      expect { Primo::Search::Query::build(nil) }.to raise_error(::Primo::Search::SearchError)
    end
  end

  context "pass [] as an argument" do
    it "raises an error" do
      expect { Primo::Search::Query::build([]) }.to raise_error(::Primo::Search::SearchError)
    end
  end

  context "pass invalid [query]" do
    let(:query) { {
      precision: :foo,
      field: :title,
      value: "bar"
    } }
    it "raises a query error" do
      expect { Primo::Search::Query::build([query]) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context "pass valid [query]" do
    let(:query) { {
      precision: :contains,
      field: :title,
      value: "bar",
      operator: :OR,
    } }
    it "it returns a Query" do
      expect(Primo::Search::Query::build([query])).to be_an_instance_of(Primo::Search::Query)
    end

    it "transforms to an expected string" do
      expect(Primo::Search::Query::build([query]).to_s).to eq("title,contains,bar,OR")
    end
  end

  context "pass multiple valid [queries]" do
    let(:query) { {
      precision: :contains,
      field: :title,
      value: "foo",
      operator: :NOT,
    } }
    let(:query_2) { {
      precision: :contains,
      field: :title,
      value: "bar",
      operator: :AND,
    } }
    it "it returns a Query" do
      expect(Primo::Search::Query::build([query, query, query_2])).to be_an_instance_of(Primo::Search::Query)
    end

    it "transforms to an expected string" do
      expect(Primo::Search::Query::build([query, query_2]).to_s).to eq("title,contains,foo,NOT;title,contains,bar,AND")
    end
  end

  context "pass mixed valid and invalid [queries]" do
    let(:query) { {
      precision: :contains,
      field: :title,
      value: "bar",
      operator: :OR,
    } }
    it "it raises a query error" do
      expect { Primo::Search::Query::build([query, nil]) }.to raise_error(Primo::Search::Query::QueryError)
    end

    it "it raises a query error" do
      expect { Primo::Search::Query::build([nil, query]) }.to raise_error(Primo::Search::Query::QueryError)
    end
  end
end

describe "#{Primo::Search::Query} parameter validation"  do
  #{{{2 params
  context "Initialize with no arguments" do
    let(:query) { Primo::Search::Query.new }
    it "raises an argument error" do
      expect { query }.to raise_error(ArgumentError)
    end
  end

  context "Initialize with empty parameters" do
    let(:query) { Primo::Search::Query.new({}) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  #{{{2 :field
  context ":field parameter is missing" do
    let(:query) { Primo::Search::Query.new(
      precision: "contains",
      value: "foo"
    ) }
    it "Uses the default field if not provided" do
      expect { query }.to_not raise_error(Primo::Search::Query::QueryError)
    end
  end

  context ":field parameter is not known" do
    let(:query) { Primo::Search::Query.new(
      precision: :contains,
      field: :foo,
      value: "bar"
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context ":field parameter is known" do
    let(:query) { Primo::Search::Query.new(
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
    let(:query) { Primo::Search::Query.new(
      precision: :exact,
      field: :facet_local23,
      value: "bar",
      operator: :FOO
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context ":operator parameter is known" do
    let(:query) { Primo::Search::Query.new(
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
  context ":precision parameter is not known" do
    let(:query) { Primo::Search::Query.new(
      field: :any,
      value: "foo",
      precision: :foo,
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context ":precision parameter is known" do
    let(:query) { Primo::Search::Query.new(
      field: :any,
      value: "foo",
      precision: :contains,
    ) }
    it "does not raise error" do
      expect { query }.to_not raise_error
    end
  end

  context ":precision :exact not used with a facet field" do
    let(:query) { Primo::Search::Query.new(
      field: :facet_local1,
      value: "foo",
      precision: :begins_with,
    ) }
    it "raises a query error" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end


  #{{{2 :value
  context ":value parameter is missing" do
    let(:query) { Primo::Search::Query.new(
      field: :any,
      precision: :contains,
    ) }
    it "raises a query" do
      expect { query }.to raise_error(Primo::Search::Query::QueryError)
    end
  end

  context ":value including commas" do
    let(:query) { Primo::Search::Query.new(
      field: :any,
      precision: :contains,
      value: "A,B,C",
    ) }

    it "replaces commas with spaces" do
      expect(query.to_s).to include("A B C")
    end
  end

  context ":value including semicolons" do
    let(:query) { Primo::Search::Query.new(
      field: :any,
      precision: :contains,
      value: "A;B;C",
    ) }

    it "replaces semicolons with spaces" do
      expect(query.to_s).to include("A B C")
    end
  end

  describe "#{Primo::Search::Query}#to_h" do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    let(:facet1) { {
      precision: :exact,
      operation: :exclude,
      field: "creator",
      value: "bar"
    } }
    let(:facet2) { {
      precision: :exact,
      field: "format",
      value: "foo"
    } }

    context "simple query with no facets" do
      it "has one value" do
        expect(query.to_h.size).to eq(1)
      end

      it "has a :q key" do
        expect(query.to_h).to have_key(:q)
      end
    end

    context "simple query with exclude facet" do
      it "has two values" do
        query.facet(facet1)
        expect(query.to_h.size).to eq(2)
      end

      it "has a :qInclude key" do
        query.facet(facet1)
        expect(query.to_h).to have_key(:qExclude)
      end
    end

    context "simple query with include facet" do
      it "has a :qInclude key" do
        query.facet(facet2)
        expect(query.to_h).to have_key(:qInclude)
      end
    end

    context "simple query with include and exclude facets" do
      it "has 3 values" do
        query.facet(facet1).facet(facet2)
        expect(query.to_h.size).to eq(3)
      end
    end
  end


  describe "#{Primo::Search::Query}#facet"  do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    context "given a valid facet params" do
      let(:facet) { {
        precision: :exact,
        operation: :include,
        field: "creator",
        value: "bar"
      } }
      it "transforms to an expected string" do
        expect(query.facet(facet).include_facets).to eq("facet_creator,exact,bar")
      end
    end
    context "given a valid exlude facet params" do
      let(:facet) { {
        precision: :exact,
        operation: :exclude,
        field: "creator",
        value: "bar"
      } }
      it "transforms to an expected string" do
        expect(query.facet(facet).exclude_facets).to eq("facet_creator,exact,bar")
      end
    end
    context "given a multiple facets" do
      let(:facet1) { {
        precision: :exact,
        operation: :include,
        field: "creator",
        value: "bar"
      } }
      let(:facet2) { {
        precision: :exact,
        operation: :include,
        field: "format",
        value: "foo"
      } }
      it "transforms to an expected string" do
        expect(query.facet(facet1).facet(facet2).include_facets).to eq("facet_creator,exact,bar|,|facet_format,exact,foo")
      end
    end
    context "given an include and exclude facet" do
      let(:facet1) { {
        precision: :exact,
        operation: :exclude,
        field: "creator",
        value: "bar"
      } }
      let(:facet2) { {
        precision: :exact,
        operation: :include,
        field: "format",
        value: "foo"
      } }
      it "correctly asigns include and exclude facets" do
        query.facet(facet1).facet(facet2)
        expect(query.include_facets).to eq("facet_format,exact,foo")
        expect(query.exclude_facets).to eq("facet_creator,exact,bar")
      end
    end

  end

  describe "#{Primo::Search::Query}#date_range_facet"  do
    let(:query) {
      Primo.configure {}
      Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
      ) }
    context "do not provide min or max" do
      it "provides defaults min and max" do
        expect(query.date_range_facet.include_facets).to eq("facet_searchcreationdate,exact,[1000 TO 9999]")
      end
    end

    context "only provide min" do
      it "provides default max" do
        expect(query.date_range_facet(min: 1).include_facets).to eq("facet_searchcreationdate,exact,[1 TO 9999]")
      end
    end

    context "only provide max" do
      it "provides default min" do
        expect(query.date_range_facet(max: 1).include_facets).to eq("facet_searchcreationdate,exact,[1000 TO 1]")
      end
    end

    context "only provides min and max" do
      it "provides default min and max" do
        expect(query.date_range_facet(min: 1, max: 2).include_facets).to eq("facet_searchcreationdate,exact,[1 TO 2]")
      end
    end

    context "provides min, max and operator" do
      it "provides default min and max" do
        q = query.date_range_facet(min: 1, max: 2, operation: :exclude)
        include_facets = q.include_facets
        exclude_facets = q.exclude_facets
        expect(include_facets).to be_nil
        expect(exclude_facets).to eq("facet_searchcreationdate,exact,[1 TO 2]")
      end
    end

    context "min and max are empty strings" do
      it "provides default min and max" do
        q = query.date_range_facet(min: "", max: "  ")
        include_facets = q.include_facets
        expect(include_facets).to eq("facet_searchcreationdate,exact,[1000 TO 9999]")
      end
    end

    context "random nonsense years" do
      it "provides default min and max" do
        q = query.date_range_facet(min: "foo", max: "bar")
        include_facets = q.include_facets
        expect(include_facets).to eq("facet_searchcreationdate,exact,[1000 TO 9999]")
      end
    end

  end
end
