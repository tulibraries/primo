# frozen_string_literal: true

require "spec_helper"

RSpec.describe "#{Primo::Pnxs}#get" do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_get"
    Primo.configure
  end

  after(:all) do
    VCR.eject_cassette
    Primo.configuration = nil
  end

  context "passing nil" do
    it "should throw a pnxs error" do
      expect { Primo::Pnxs::get() }.to raise_error(Primo::Pnxs::PnxsError)
      expect { Primo::Pnxs::get nil }.to raise_error(Primo::Pnxs::PnxsError)
    end
  end

  context "passing invalid query" do
    let(:options) { { q: nil } }

    it "should throw a pnxs error" do
      expect { Primo::Pnxs::get(options) }.to raise_error(Primo::Pnxs::PnxsError)
    end
  end

  context "passing a valid query with unknown option" do
    let(:options) {
      q = Primo::Pnxs::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
        operator: :OR,
      )
      { q: q, foo: "bar" }
    }

    it "should throw a pnxs error" do
      expect { Primo::Pnxs::get(options) }.to raise_error(Primo::Pnxs::PnxsError)
    end
  end

  context "passing a valid query" do
    let(:options) {
      q = Primo::Pnxs::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
      { q: q }
    }

    it "should not throw errors" do
      expect { Primo::Pnxs::get(options) }.to_not raise_error
    end

    it "should return an instance of Pnxs" do
      expect(Primo::Pnxs::get(options)).to be_an_instance_of(Primo::Pnxs)
    end
  end
end

RSpec.describe Primo::Pnxs do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_get"
    Primo.configure
  end

  after(:all) do
    VCR.eject_cassette
    Primo.configuration = nil
  end

  let(:pnxs) {
    q = Primo::Pnxs::Query.new(
      precision: :contains,
      field: :title,
      value: "otter",
      operator: :OR,
    )
    Primo::Pnxs::get q: q
  }

  it "should headers" do
  end

  it "should return an instance of Pnxs" do
  end
end
