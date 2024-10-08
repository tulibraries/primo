# frozen_string_literal: true

require "httparty"
require "forwardable"

module Primo
  # Encapsulates the Primo Search REST API
  class Search
    class SearchError < StandardError
      def initialize(message, loggable = {})
        if Primo.configuration.enable_loggable
          message = loggable.merge(error: message).to_json
        end

        super message
      end
    end

    class ArticleNotFound < SearchError
    end

    include HTTParty
    include Primo::ParameterValidatable
    include Enumerable
    extend Forwardable

    def_delegators :@response, :each, :<<

    attr_reader :response, :fields, :loggable

    def initialize(response, method)
      @response = response
      @loggable = method.loggable

      validate response
      # Give the query method a chance to test response.
      method.validate_response(response)

      # object attribute readers that begin with @ throw an error.
      @fields = response.keys
        .map { |k| k.gsub(/^@/, "_") }
      initialize_fields response
    end

    def [](x)
      self.send(x)
    end

    # Overrides HTTParty::get in order to add some custom validations.
    def self.get(params = {})
      params = params.to_h.transform_keys(&:to_sym)
      method = get_method params
      (url, query) = url(params)

      retry_count = Primo.configuration.enable_retries ? Primo.configuration.retries : 0
      begin
        new super(url, query:, timeout: Primo.configuration.timeout(params)), method
      rescue Net::ReadTimeout
        if (Primo.configuration.retries && (retry_count -= 1) > 0)
          Primo.configuration.logger.warn("Primo request timed out. Retrying. [#{retry_count}]")
          retry
        end
        raise "Primo request timed out"
      # Ignore Test Mock related error
      rescue RSpec::Mocks::MockExpectationError
        nil
      rescue => e
        Primo.configuration.logger.error(e.message)
        nil
      end
    end

    def self.url(params = {})
      method = get_method params
      [method.url, method.params]
    end


  private
    # Base class for classes encapsulating Primo REST API methods.
    class BaseSearchMethod
      include Primo::ParameterValidatable

      def initialize(params = {})
        validate(params)
        @params = params
      end

      def loggable
        { url:, query: @params }
          .select { |k, v| !v.nil? }
      end

      def validate_response(response)
      end

      protected
        def auth(env = :hosted)
          env ||= :hosted
          auths = {
            hosted: { apikey: Primo.configuration.apikey },
            local: { inst: Primo.configuration.inst },
          }
          auths[env]
        end

        def vid_scope
          vid = Primo.configuration.vid
          scope = Primo.configuration.scope

          if (vid && scope) || (vid.nil? && scope.nil?)
            { vid:, scope: }
          else
            error = "Both or neither of :vid or :scope must be configured"
            throw Primo::Search::SearchError.new error, loggable
          end
        end

        RESOURCE = "/primo/v1/search"
    end

    # Encapsulates the GET /v1/search Primo REST API Method URL and Parameters.
    class SearchMethod < BaseSearchMethod
      def url
        Primo.configuration.region + "/primo/v1/search"
      end

      def params
        query = @params[:q] || @params["q"]
        # Add defaults and allow override of defaults via @params.
        {}.merge(auth)
          .merge(vid_scope)
          .merge(query.to_h)
          .merge(pcAvailability: Primo.configuration.pcavailability)
          .merge(@params.slice(*@params.keys - [:q, "q"]))
      end

      def self.can_process?(params = {})
        params ||= {}
        params.include?(:q)
      end

      private

        PARAMETER_KEYS = %i(
          inst q qInclude qExclude lang offset limit sort
          view addfields vid scope searchCDI
          apikey inst pcAvailability pcavailability vid scope
        )

        def validators
          [{ query: :has_valid_query?,
             message: lambda { |p| "field :q must be a valid instance of Primo::Search::Query " } },
          { query: :only_known_parameters?,
            message: lambda { |p| "only known parameters can be passed " } },
          ]
        end

        def has_valid_query?(params)
          params[:q].is_a?(Primo::Search::Query)
        end

        def only_known_parameters?(params)
          (params.keys - PARAMETER_KEYS - PARAMETER_KEYS.map(&:to_s)).empty?
        end
    end

    class RecordMethod < SearchMethod
      def self.can_process?(params = {})
        params ||= {}
        params.include?(:id) && params[:id].present?
      end

      def validate_response(response)
        message = "The article for id #{@params[:id]} was not found."
        raise ArticleNotFound.new(message, loggable) unless response.dig("pnx", "search", "title")
      end
    end

    # Catch all Method.
    class DefaultMethod < BaseSearchMethod
      attr_reader :url

      def initialize(params = {})
        raise SearchError.new "No method found to process given parameters.", loggable
      end

      def self.can_process?(params = {})
        true
      end
    end

    REGISTERED_METHODS = [SearchMethod, RecordMethod, DefaultMethod]

    def self.get_method(params)
      REGISTERED_METHODS
        .find { |m| m.can_process? params }
        .new(params)
    end

    def validators
      [
        { query: :is_200?,
          message: lambda { |r| "Attempting to work with an invalid response: #{r.code}\nEndpoint: #{r.request.uri}" } }
      ]
    end

    def is_200?(response)
      response.respond_to?(:code) && response.code == 200
    end

    def initialize_fields(response)
      @fields.each do |f|
        self.class.send(:attr_reader, f)
        obj = to_struct(response["#{f.gsub(/^_/, "@")}"])
        instance_variable_set("@#{f}", obj)
      end
    end

    # Allows us to access returned data using dot notation.
    def to_struct(obj)
      if obj.is_a? Hash
        OpenStruct.new obj
      elsif obj.is_a? Array
        obj.map { |o| to_struct o }
      else
        obj
      end
    end
  end
end
