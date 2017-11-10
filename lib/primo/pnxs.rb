# frozen_string_literal: true

require "httparty"

module Primo
  class Pnxs
    class PnxsError < ArgumentError
    end

    include HTTParty

    def initialize(response)
      validate response
    end

    # Overrides HTTParty::get in order to add some custom validations.
    def self.get(params = {})
      validate params
      params.merge! apikey: Primo.configuration.apikey, q: params[:q].to_s
      url = Primo.configuration.region + RESOURCE
      new super(url, query: params)
    end

  private
    RESOURCE = "/primo/v1/pnxs"

    PARAMETER_KEYS = %i(
      inst q qInclude qExclude lang offset limit sort
      view addfields vid scope
    )
    VALIDATORS = [
      { query: :is_200?,
        message: lambda { |r| "Attempting to work with an invalid response: #{r.code}" } },
    ]
    GET_VALIDATORS = [
      { query: :has_query?,
        message: lambda { |p| "field :q is required " } },
      { query: :only_known_parameters?,
        message: lambda { |p| "field :q is required " } },
    ]

    def validate(response)
      response ||= {}
      VALIDATORS.each { |validate|
        message = validate[:message][response]
        raise PnxsError.new(message) unless self.send(validate[:query], response)
      }
    end

    def is_200?(response)
      response.respond_to?(:code) && response.code == 200
    end

    def self.validate(params)
      params ||= {}
      GET_VALIDATORS.each { |validate|
        message = validate[:message][params]
        raise PnxsError.new(message) unless self.send(validate[:query], params)
      }
    end

    def self.has_query?(params)
      params.include?(:q) && params[:q].instance_of?(Query)
    end

    def self.only_known_parameters?(params)
      (params.keys - PARAMETER_KEYS).empty?
    end
  end
end
