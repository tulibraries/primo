# frozen_string_literal: true

require "spec_helper"

describe "Configuring Primo" do
  before do
    Primo.configure
  end

  after do
    Primo.configuration = nil
  end

  context "when no attributes are set in the passed block" do

    it "uses default values" do
      expect(Primo.configuration.apikey).to eql "TEST_API_KEY"
      expect(Primo.configuration.inst).to eql "TEST_INSTITUTE_KEY"
      expect(Primo.configuration.region).to eql "https://api-na.hosted.exlibrisgroup.com"
      expect(Primo.configuration.operator).to eql :AND
      expect(Primo.configuration.field).to eql :any
      expect(Primo.configuration.precision).to eql :contains
      expect(Primo.configuration.context).to eql :L
      expect(Primo.configuration.environment).to eql :hosted
      expect(Primo.configuration.vid).to eql nil
      expect(Primo.configuration.scope).to eql nil
      expect(Primo.configuration.pcavailability).to eql false
      expect(Primo.configuration.timeout).to eql 5
      expect(Primo.configuration.retries).to eql 3
      expect(Primo.configuration.enable_retries).to eql false
      expect(Primo.configuration.validate_parameters).to eql true
      expect(Primo.configuration.enable_log_requests).to eql false
      expect(Primo.configuration.logger).to be_instance_of(Logger)
      expect(Primo.configuration.log_level).to eq(:info)
      expect(Primo.configuration.enable_debug_output).to eql false
      expect(Primo.configuration.debug_output_stream).to eq($stderr)
    end
  end

  context "params set limit of 50" do
    it "doubles the default timeout" do
      expect(Primo.configuration.timeout("limit" => 50)).to eql 10
    end
  end

  context "Override Timeout Retries" do
    before do
      Primo.configure do |config|
        config.enable_retries = true
        config.retries = 5
      end
    end

    it "is possible to override enable timeout" do
      expect(Primo.configuration.enable_retries).to eql true
    end

    it "is possible to override timeout retries to 5" do
      expect(Primo.configuration.retries).to eql 5
    end
  end

  context "when attributes are set in the passed block" do
    before do
      Primo.configure do |config|
        config.apikey =  "SOME_OTHER_API_KEY"
      end
    end

    it "overrides value for attribute if overridden" do
      expect(Primo.configuration.apikey).to eql "SOME_OTHER_API_KEY"
    end

    it "sets the default value for attributes not overriden" do
      expect(Primo.configuration.region).to eql "https://api-na.hosted.exlibrisgroup.com"
    end

    it "is possible to override vid and scope" do
      Primo.configure do |config|
        config.vid =  :default_vid
        config.scope = :default_scope
      end

      expect(Primo.configuration.vid).to eql :default_vid
      expect(Primo.configuration.scope).to eql :default_scope
    end
  end

  context "when we enable logging via configuration" do
    before do
      Primo.configure do |config|
        config.enable_log_requests = true
      end
    end

    it "should eanble logging in Primo::Search class" do
      expect(Primo::Search.default_options[:logger]).to eq(Primo.configuration.logger)
      expect(Primo::Search.default_options[:log_level]).to eq(Primo.configuration.log_level)
      expect(Primo::Search.default_options[:log_format]).to eq(Primo.configuration.log_format)
    end
  end

  context "when we enable debugging via configuration" do
    before do
      Primo.configure do |config|
        config.enable_debug_output = true
      end
    end

    it "should set debugging options for Primo::Search class" do
      expect(Primo::Search.default_options[:debug_output]).to eq(Primo.configuration.debug_output_stream)
    end
  end

end
