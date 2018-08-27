# frozen_string_literal: true

require "httparty"
require "forwardable"

module Primo
  # Encapsolates the Primo PNXS REST API
  class Pnxs
    class PnxsError < ArgumentError
    end


    include HTTParty
    include Primo::ParameterValidatable
    include Enumerable
    extend Forwardable

    def_delegators :@response, :each, :<<

    attr_reader :response, :fields

    def initialize(response)
      validate response
      @response = response
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
      method = get_method params
      new super(method.url, query: method.params)
    end

  private
    # Base class for classes encapsolating Primo REST API methods.
    class PnxsMethod
      include Primo::ParameterValidatable

      def initialize(params = {})
        validate(params)
        @params = params
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
            { vid: vid, scope: scope }
          else
            error = "Both or neither of :vid or :scope must be configured"
            throw Primo::Pnxs::PnxsError.new error
          end
        end

        RESOURCE = "/primo/v1/pnxs"
    end

    # Encapsolates the GET /v1/pnxs Primo REST API Method URL and Parameters.
    class SearchMethod < PnxsMethod
      def url
        Primo.configuration.region + "/primo/v1/search"
      end

      def params
        query = @params[:q] || @params["q"]
        @params.merge(auth)
          .merge(vid_scope)
          .merge(query.to_h)
          .merge(pcAvailability: Primo.configuration.pcavailability)
      end

      def self.can_process?(params = {})
        params ||= {}
        params.include?(:q)
      end

      private

        PARAMETER_KEYS = %i(
          inst q qInclude qExclude lang offset limit sort
          view addfields vid scope
        )

        def validators
          [{ query: :has_valid_query?,
             message: lambda { |p| "field :q must be a valid instance of Primo::Pnxs::Query " } },
          { query: :only_known_parameters?,
            message: lambda { |p| "only known parameters can be passed " } },
          ]
        end

        def has_valid_query?(params)
          params[:q].is_a?(Primo::Pnxs::Query)
        end

        def only_known_parameters?(params)
          (params.keys - PARAMETER_KEYS - PARAMETER_KEYS.map(&:to_s)).empty?
        end
    end

    # Encapsolates the GET /v1/pnxs/{context}/{recordId} Primo REST API Method
    # URL and Parameters.
    class RecordMethod < PnxsMethod
      def url
        context = @params[:context] || Primo.configuration.context
        id = CGI.unescape(@params[:id])
        url = Primo.configuration.region + RESOURCE + "/#{context}/#{id}"

        if (URI.parse url rescue false)
          url
        else
          Primo.configuration.region + RESOURCE + "/#{context}/#{CGI.escape(id)}"
        end
      end

      def params
        @params.select { |k, v| !URL_KEYS.include? k }
          .merge auth
      end

      def self.can_process?(params = {})
        params ||= {}
        params.include?(:id)
      end

      private

        URL_KEYS = %i(id context)
        PARAMETER_KEYS = %i( inst lang )

        def validators
          [
          { query: :only_known_parameters?,
            message: lambda { |p| "only known parameters are passed " } },
          ]
        end

        def only_known_parameters?(params)
          keys = (PARAMETER_KEYS + URL_KEYS)
          string_keys = keys.map(&:to_s)
          (params.keys - keys - string_keys).empty?
        end
    end

    # Catch all Method.
    class DefaultMethod < PnxsMethod
      def initialize(params = {})
        raise PnxsError.new "No method found to process given parameters."
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
          message: lambda { |r| "Attempting to work with an invalid response: #{r.code}" } },
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
