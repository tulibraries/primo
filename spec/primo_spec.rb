# frozen_string_literal: true

require "spec_helper"

RSpec.describe Primo do
  it "has a version number" do
    expect(Primo::VERSION).not_to be nil
  end

  it "defines a Pnxs class" do
    expect(Primo::Pnxs).not_to be nil
  end
end

