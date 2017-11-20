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
    it "should raise a pnxs error" do
      expect { Primo::Pnxs::get() }.to raise_error(Primo::Pnxs::PnxsError)
      expect { Primo::Pnxs::get nil }.to raise_error(Primo::Pnxs::PnxsError)
    end
  end

  context "passing invalid query" do
    let(:options) { { q: nil } }

    it "should raise a pnxs error" do
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

    it "should raise a pnxs error" do
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

    it "should not raise errors" do
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

  it "should respond to :docs with non nil" do
    expect(pnxs.docs).not_to be_nil
  end

  it "should respond to :timelog with non nil" do
    expect(pnxs.timelog).not_to be_nil
  end

  it "should respond to :lang3 with non nil" do
    expect(pnxs.lang3).not_to be_nil
  end

  it "should respond to :info with non nil" do
    expect(pnxs.info).not_to be_nil
  end

  it "should respond to :facets with non nil" do
    expect(pnxs.facets).not_to be_nil
  end

  it "should respond to :beaconO22 with non nil" do
    expect(pnxs.beaconO22).not_to be_nil
  end

  it "docs should respond to fields" do
    expect(pnxs.docs.first.date).to eq("1995")
    expect(pnxs.docs.first["date"]).to eq("1995")
  end

  context "getting 400 response from server" do
    let(:pnxs) {

      stub_request(:get, /.*www\.foobar\.com\/.*/).
      to_return(status: 400, body: "Hello World")

      Primo.configure { |c| c.region = "https://www.foobar.com" }

      q = Primo::Pnxs::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
      Primo::Pnxs::get q: q
    }

    it "should raise a pnxs error" do
      expect { pnxs }.to raise_error(Primo::Pnxs::PnxsError)
    end
  end
end
