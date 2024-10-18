# frozen_string_literal: true

require "logger"

module Primo
  class << self
    attr_accessor :configuration
  end

  def self.configure()
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
    on_configure
  end

  def self.on_configure
    _configure_logging
    _configure_debugging
  end


  def self._configure_logging
    if configuration.enable_log_requests
      primo_logger = configuration.logger
      log_level = Primo.configuration.log_level
      log_format = Primo.configuration.log_format
      Primo::Search.logger primo_logger, log_level, log_format
    end
  end

  def self._configure_debugging
    if configuration.enable_debug_output
      Primo::Search.debug_output configuration.debug_output_stream
    end
  end

  class Configuration
    attr_accessor :apikey, :region, :operator, :field, :precision
    attr_accessor :context, :environment, :inst, :vid, :scope, :pcavailability, :enable_loggable
    attr_accessor :timeout, :validate_parameters, :enable_log_requests, :enable_debug_output
    attr_accessor :logger, :log_level, :log_format, :debug_output_stream, :enable_retries, :retries

    def initialize
      @apikey = "TEST_API_KEY"
      @inst = "TEST_INSTITUTE_KEY"
      @region = "https://api-na.hosted.exlibrisgroup.com"
      @operator = :AND
      @field = :any
      @precision = :contains
      @context = :L
      @environment = :hosted
      @pcavailability = false
      @enable_loggable = false
      @timeout = 5
      @retries = 3
      @enable_retries = false
      @validate_parameters = true
      @enable_log_requests = false
      # debug_output should only be enabled in development mode.
      @enable_debug_output = false
      @logger = Logger.new("log/primo_requests.log")
      @log_level = :info
      @log_format = :logstash
      @debug_output_stream = $stderr
    end

    def timeout(params = {})
      limit = params.fetch("limit", 10).to_i
      if limit >= 50
        2 * @timeout
      else
        @timeout
      end
    end
  end
end
