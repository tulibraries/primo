# frozen_string_literal: true

require "spec_helper"

RSpec.describe "#{Primo::PnxsById}#get" do
  before(:all) do
    VCR.insert_cassette "primo_pnxs_by_id_get"
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

  it "responds to #get" do
    expect(Primo::PnxsById).to respond_to(:get)
  end

end
