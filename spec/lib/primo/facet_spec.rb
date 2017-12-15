# frozen_string_literal: true

require "spec_helper"

describe Primo::Pnxs::Facet  do
  context "pass minimal parameters" do
    let(:facet) { described_class.new(
      field: "creator",
      value: "bar"
    )}
    it "transforms to an expected string with defaults" do
      expect(facet).to be_a Primo::Pnxs::Facet
    end
  end
  context "Builds an exclude facet" do
    let(:facet) { described_class.new(
      field: "creator",
      value: "a creator",
      operation: :exclude
    ) }
    it "successfully builds an exclude facet" do
      expect(facet.operation).to eql(:exclude)
    end
  end
  context "params don't include :field" do
    let(:facet) { described_class.new(
      value: "bar"
    ) }
    it "raises an error" do
      expect { facet }.to raise_error(Primo::Pnxs::Facet::FacetError)
    end
  end
  context "params don't include :value" do
    let(:facet) { described_class.new(
      field: "creator"
    ) }
    it "transforms to an expected string with defaults" do
      expect { facet }.to raise_error(Primo::Pnxs::Facet::FacetError)
    end
  end
end
