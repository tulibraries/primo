# frozen_string_literal: true

require "spec_helper"

RSpec.describe "#{Primo::Search}#get" do
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
      expect { Primo::Search::get() }.to raise_error(Primo::Search::SearchError)
      expect { Primo::Search::get nil }.to raise_error(Primo::Search::SearchError)
    end
  end

  context "passing invalid query" do
    let(:options) { { q: nil } }

    it "should raise a pnxs error" do
      expect { Primo::Search::get(options) }.to raise_error(Primo::Search::SearchError)
    end
  end

  context "passing a valid query with unknown option" do
    let(:options) {
      q = Primo::Search::Query.new(
        precision: :exact,
        field: :facet_local23,
        value: "bar",
        operator: :OR,
      )
      { q: q, foo: "bar" }
    }

    it "should raise a pnxs error" do
      expect { Primo::Search::get(options) }.to raise_error(Primo::Search::SearchError)
    end
  end

  context "passing a valid query" do
    let(:options) {
      q = Primo::Search::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
      { q: q }
    }

    it "should not raise errors" do
      expect { Primo::Search::get(options) }.to_not raise_error
    end

    it "should return an instance of Search" do
      expect(Primo::Search::get(options)).to be_an_instance_of(Primo::Search)
    end

    it "adds the apikey to the query" do
      method = Primo::Search.send(:get_method, options)
      expect(method.params).to have_key(:apikey)
      expect(method.params).to have_value("TEST_API_KEY")
    end

  end
end

RSpec.describe Primo::Search do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_get"
    Primo.configure
  end

  after(:all) do
    VCR.eject_cassette
    Primo.configuration = nil
  end

  let(:pnxs) {
    q = Primo::Search::Query.new(
      precision: :contains,
      field: :title,
      value: "otter",
      operator: :OR,
    )
    Primo::Search::get q: q
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

      q = Primo::Search::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
      Primo::Search::get q: q
    }

    it "should raise a pnxs error" do
      expect { pnxs }.to raise_error(Primo::Search::SearchError)
    end

    it "should capture the primo endpoint and status code" do
      stub_request(:get, /.*www\.foobar\.com\/.*/).
      to_return(status: 500, body: "Nope")

      Primo.configure { |c| c.region = "https://www.foobar.com" }

      q = Primo::Search::Query.new(
        precision: :contains,
        field: :title,
        value: "otter",
        operator: :OR,
      )
      expect { Primo::Search::get q: q }.to raise_error { |error|
        lines = error.message.split("\n")
        expect(lines[0]).to eq "Attempting to work with an invalid response: 500"
        expect(lines[1]).to eq "Endpoint: https://www.foobar.com/primo/v1/search?q=title%2Ccontains%2Cotter%2COR&apikey=TEST_API_KEY&vid=&scope=&pcAvailability=false"
      }
    end
  end
end
