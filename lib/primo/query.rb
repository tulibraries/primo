# frozen_string_literal: true

# The query parameter :q for the Primo pnxs API is a structured string with
# some rules associated to specific field.  This class encapsolates that
# structure and those rules:
#
# For mor details see:
# https://developers.exlibrisgroup.com/primo/apis/webservices/rest/pnxs
# https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch

class Primo::Pnxs::Query
  class QueryError < ArgumentError
  end

  def initialize(params)
    @queries = []
    @include_facets = []
    @exclude_facets = []
    push params
  end

  def and(params)
    push(params, :AND)
  end

  def or(params)
    push(params, :OR)
  end

  def not(params)
    push(params, :NOT)
  end

  def self.build(queries)
    queries ||= []
    first_query = queries.pop
    query = new(first_query)
    queries.each { |q|
      query.send(:push, q)
    }
    query
  end

  def to_s
    @queries.map { |q| transform q }
      .join(";")
  end

  def to_h
    {
      q: to_s,
      qInclude: include_facets,
      qExclude: exclude_facets,
    }
      .select { |k, v| !v.nil? }
      .to_h
  end

  def facet(params)
    facet = Primo::Pnxs::Facet.new(params)
    if facet.operation == :exclude
      @exclude_facets.push(facet)
    else
      @include_facets.push(facet)
    end
    # Return the Query object so multiple facet calls can be chained together
    self
  end

  def include_facets
    if !@include_facets.empty?
      @include_facets.map(&:to_s).join("|,|")
    end
  end

  def exclude_facets
    if !@exclude_facets.empty?
      @exclude_facets.map(&:to_s).join("|,|")
    end
  end

  private
    REQUIRED_PARAMS = [ :field, :precision, :value ]
    OPTIONAL_PARAMS = [ :operator ]
    PARAM_ORDER = [ :field, :precision, :value, :operator ]
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

    def push(params, operator = nil)
      params ||= {}
      operator = operator || params[:operator] || Primo.configuration.operator
      query = @queries.pop

      if query
        @queries.push(query.merge(operator: operator))
      end

      validate(params) && @queries.push(params)
      self
    end

    def validate(params)
      params ||= {}
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

    def transform(query)
      PARAM_ORDER.map { |p|
        if self.respond_to?(p, true)
          self.send(p, query[p])
        else
          query[p]
        end

      }.join(",")
    end

    def value(value)
      value.tr(",", " ")
    end

    def operator(value)
      value || Primo.configuration.operator
    end
end
