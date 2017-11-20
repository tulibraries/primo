# frozen_string_literal: true

require "primo/pnxs"

class Primo::PnxsById
  include HTTParty

  def initialize(response)
    validate response
    initialize_fields response
  end

  # Overrides HTTParty::get in order to add some custom validations.
  def self.get(id, params = {})
    validate id, params
    new super(get_url, query: params)
  end

  private

    def self.get_url
      Primo.configuration.region + RESOURCE + "/#{id}"
    end
end
