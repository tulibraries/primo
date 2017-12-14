# frozen_string_literal: true

require "spec_helper"

describe "Configuring Primo" do

  context "when no attributes are set in the passed block" do

    before(:all) do
      Primo.configure {}
    end

    it "uses default values" do
      expect(Primo.configuration.apikey).to eql "TEST_API_KEY"
      expect(Primo.configuration.inst).to eql "TEST_INSTITUTE_KEY"
      expect(Primo.configuration.region).to eql "https://api-na.hosted.exlibrisgroup.com"
      expect(Primo.configuration.operator).to eql :AND
      expect(Primo.configuration.field).to eql :any
      expect(Primo.configuration.precision).to eql :contains
      expect(Primo.configuration.context).to eql :L
      expect(Primo.configuration.environment).to eql :hosted
    end

    after(:all) do
      Primo.configuration = nil
    end
  end

  context "when attributes are set in the passed block" do
    before(:all) do
      Primo.configure do |config|
        config.apikey =  "SOME_OTHER_API_KEY"
      end
    end

    it "default value for that attribute is overridden" do
      expect(Primo.configuration.apikey).to eql "SOME_OTHER_API_KEY"
    end

    it "still sets the default value for attributes not overriden" do
      expect(Primo.configuration.region).to eql "https://api-na.hosted.exlibrisgroup.com"
    end

    after(:all) do
      Primo.configuration = nil
    end
  end
end
