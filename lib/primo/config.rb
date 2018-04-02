# frozen_string_literal: true

module Primo
  class << self
    attr_accessor :configuration
  end

  def self.configure()
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :apikey, :region, :operator, :field, :precision
    attr_accessor :context, :environment, :inst, :vid, :scope

    def initialize
      @apikey = "TEST_API_KEY"
      @inst = "TEST_INSTITUTE_KEY"
      @region = "https://api-na.hosted.exlibrisgroup.com"
      @operator = :AND
      @field = :any
      @precision = :contains
      @context = :L
      @environment = :hosted
    end
  end
end
