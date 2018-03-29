# frozen_string_literal: true

require "primo/version"
require "primo/config"
require "primo/parameter_validatable"
require "primo/pnxs"
require "primo/query"
require "primo/facet"

module Primo
  def self.find(options = {})
    options ||= {}

    if options.is_a? String
      params = find_defaults(value: options)
      query = Primo::Pnxs::Query.new params
      return find(q: query)
    end

    if options.fetch(:id, nil)
      return find_by_id(options)
    end

    if  options.fetch(:q, {}).is_a? Hash
      query = Primo::Pnxs::Query.new(find_defaults options[:q])
      return find(options.merge(q: query))
    end

    Primo::Pnxs::get(options)
  end

  def self.find_by_id(params = {})
    params ||= {}

    if params.is_a? String
      return find_by_id(id: params)
    end

    Primo::Pnxs::get(id_defaults(params))
  end

  private

    def self.find_defaults(params)
      params ||= {}
      field = params[:field] || Primo.configuration.field
      precision = params[:precision] || Primo.configuration.precision
      params.merge(field: field, precision: precision)
    end

    def self.id_defaults(params)
      params ||= {}
      context = params[:context] || Primo.configuration.context
      params.merge(context: context)
    end
end
