# frozen_string_literal: true

require "spec_helper"

RSpec.describe Primo do
  it "has a version number" do
    expect(Primo::VERSION).not_to be nil
  end

  it "defines a Pnxs class" do
    expect(Primo::Pnxs).not_to be nil
  end

  it "responds to find" do
    expect(Primo).to respond_to(:find)
  end

  it "responds to find_by_id" do
    expect(Primo).to respond_to(:find_by_id)
  end
end

RSpec.describe "Primo.find" do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_get"
    Primo.configure
  end

  after(:all) do
    VCR.eject_cassette
    Primo.configuration = nil
  end

  context "when we pass it nil" do
    it "raises a query error" do
      expect { Primo.find }.to raise_error Primo::Pnxs::Query::QueryError
    end
  end

  context "when we pass an empty set of options" do
    it "raises a query error" do
      expect { Primo.find }.to raise_error Primo::Pnxs::Query::QueryError
    end
  end

  context "when we pass options with valid q hash" do
    let(:query) {
      Primo::Pnxs::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
    }
    it "does not raise a query error" do
      expect { Primo.find q: query }.not_to raise_error
    end
  end

  context "when we pass options with valid q hash" do
    let(:query) {
      Primo::Pnxs::Query.new(
        "precision" =>  "contains",
        "field" => "title",
        "value" =>  "otter",
        "opterator" => "OR",
      )
    }
    it "does not raise a query error" do
      expect { Primo.find q: query }.not_to raise_error
    end
  end

  context "when we pass options with valid q Query instance" do
    let(:query) {
      { precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR, }
    }
    it "does not raise a query error" do
      expect { Primo.find q: query }.not_to raise_error
    end
  end

  context "when we pass a string" do
    let(:query) { "Otter" }

    it "does not raise a query error" do
      expect { Primo.find query }.not_to raise_error
    end
  end

  context "when we pass object with id" do
    let(:query) {  { id: "foo" } }

    it "does not raise a query error" do
      expect { Primo.find query }.not_to raise_error
    end
  end
end

RSpec.describe "Primo.find_by_id" do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_get_record"
    Primo.configure {}
  end

  after(:all) do
    VCR.eject_cassette
    Primo.configuration = nil
  end

  context "pass in nil" do
    it "raises an error if we pass in nothing" do
      expect { Primo.find_by_id }.to raise_error Primo::Pnxs::PnxsError
    end

    it "raises an error if we pass in nil" do
      expect { Primo.find_by_id nil }.to raise_error Primo::Pnxs::PnxsError
    end
  end

  context "pass in empty hash" do
    it "raises an error if we pass in an empty hash" do
      expect { Primo.find_by_id {} }.to raise_error Primo::Pnxs::PnxsError
    end
  end

  context "pass in a valid string" do
    let(:record_id) { "01TULI_ALMA51382615180003811" }
    let(:record) { Primo.find_by_id record_id }

    it "does not raise an error if we pass in a string" do
      expect { record }.to_not raise_error
    end

    it "applies record fields to the record object" do
      expect(record.title).to_not be_nil
    end
  end

  context "pass in a valid hash" do
    let(:record_id) { "01TULI_ALMA51382615180003811" }
    let(:record) { Primo.find_by_id(id: record_id) }

    it "does not raise an error if we pass in a valid hash" do
      expect { record }.to_not raise_error
    end

    it "applies record fields to the record object" do
      expect(record.title).to_not be_nil
    end
  end
end
