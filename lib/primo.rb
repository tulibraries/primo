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
      query = Primo::Pnxs::Query.new(value: options)
      return find(q: query)
    end

    if  options.fetch(:q, nil).is_a? Hash
      query = Primo::Pnxs::Query.new(options[:q])
      return find(options.merge(q: query))
    end

    Primo::Pnxs::get(options)
  end

  def self.find_by_id(params = {})
    params ||= {}

    if params.is_a? String
      return find_by_id(id: params)
    end

    Primo::Pnxs::get(params)
  end
end
