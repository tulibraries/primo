# frozen_string_literal: true

# The query parameter :q for the Primo pnxs API is a structured string with
# some rules associated to specific field.  This class encapsolates that
# structure and those rules:
#
# For mor details see:
# https://developers.exlibrisgroup.com/primo/apis/webservices/rest/pnxs
# https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch

class Primo::Pnxs::Query
  class QueryError < StandardError
  end

  def initialize(params)
    validate params
    @queries = [params]
  end

  def to_s
    @queries.map { |q| q[:value] }
      .join
      .tr(",", " ")
  end

  private
    REQUIRED_PARAMS = [ :field, :precision, :value ]
    OPTIONAL_PARAMS = [ :operator ]
    OPERATOR_VALUES = [ :AND, :OR, :NOT ]
    PRECISION_VALUES = [ :contains, :exact, :begins_with ]

    REGULAR_FIELDS = %i(
      any desc title creator sub subject rtype isbn issn rectype dlink
      ftext general toc fmt lang cdate sid rid addsrcrid addtitle
      pnxtype alttitle abstract fiction
    )
    FACET_FIELDS = %i(
      facet_creator facet_lang facet_rtype facet_pfilter facet_topic
      facet_creationdate facet_dcc facet_lcc facet_rvk
      facet_tlevelfacet_domain facet_fsize facet_fmt facet_frbrgroupid
      facet_frbrtype facet_local1 facet_local50
    ) + (1..50).to_a.map { |i| "facet_local#{i}".to_sym }

    VALIDATORS = [
        { query: :required_params_included?,
        message: lambda { |p| "All required query parameters must be included: #{REQUIRED_PARAMS.join(", ")}" } },
        { query: :field_is_known?,
          message: lambda { |p| "Attempt to use unknown field #{p[:field]}" } },
        { query: :operator_is_known?,
          message: lambda { |p| "Attempt to use an unknown logic operator #{p[:operator]}" } },
        { query: :precision_is_known?,
          message: lambda { |p| "Attempt to use an unknown precision #{p[:precision]}" } },
        { query: :facet_precision_is_exact?,
          message: lambda { |p| "Attempt to use non exact precision with facet field: #{p[:precision]}" } },
      ]

    def validate(params)
      VALIDATORS.each { |validate|
        message = validate[:message][params]
        raise QueryError.new(message) unless self.send(validate[:query], params)
      }
    end

    def required_params_included?(params)
      REQUIRED_PARAMS.map { |p| params.keys.include? p }.all?
    end

    def field_is_known?(params)
      field = params.fetch(:field)
      REGULAR_FIELDS.include?(field) || FACET_FIELDS.include?(field)
    end

    def operator_is_known?(params)
      operator = params.fetch(:operator, "")
      operator.empty? || OPERATOR_VALUES.include?(operator)
    end

    def precision_is_known?(params)
      precision = params.fetch(:precision)
      PRECISION_VALUES.include?(precision)
    end

    def facet_precision_is_exact?(params)
      precision = params.fetch(:precision)
      field = params.fetch(:field)
      REGULAR_FIELDS.include?(field) ||
        FACET_FIELDS.include?(field) && precision == :exact
    end
end
