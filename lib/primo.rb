# frozen_string_literal: true

require "primo/version"
require "primo/config"
require "primo/parameter_validatable"
require "primo/search"
require "primo/query"
require "primo/facet"

module Primo
  def self.find(options = {})
    options ||= {}

    if options.is_a? String
      query = Primo::Search::Query.new(value: options)
      return find(q: query)
    end

    return find_by_id(options) if options[:id]

    if  options[:q]&.is_a? Hash
      if options[:q][:value]&.is_a? Array
        queries = options[:q][:value]
        query = Primo::Search::Query.build(queries)
      else
        query = Primo::Search::Query.new(options[:q])
      end

      return find(options.merge(q: query))
    end

    Primo::Search::get(options)
  end

  def self.find_by_id(params = {})
    params ||= {}

    if params.is_a? String
      return find_by_id(id: params)
    end

    id = params[:id] || params["id"]

    query = Primo::Search::Query.new(
      field: "any",
      value: id,
      precision: "exact")

    find(q: query)
  end
end
