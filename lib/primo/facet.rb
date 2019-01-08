# frozen_string_literal: true

class Primo::Pnxs::Facet
  class FacetError < ::Primo::Pnxs::PnxsError
  end

  include Primo::ParameterValidatable

  attr_reader :operation, :field, :precision, :value

  def initialize(params)
    params ||= {}
    validate(params)
    @operation = params.fetch(:operation, DEFAULT_OPERATION)
    @precision = params.fetch(:precision, DEFAUlT_PRECISION)
    @field = params.fetch(:field)
    @value = params.fetch(:value)
  end

  def to_s
    "facet_#{field},#{precision},#{value}"
  end

  private

    DEFAUlT_PRECISION = :exact
    DEFAULT_OPERATION = :include

    # nil allowed because defaults will be filled in
    ALLOWED_PRECISION = [nil, :exact]
    ALLOWED_OPERATION = [nil, :include, :exclude]

    REQUIRED_PARAMS = [:field, :value]


    def validators
      [{ query: :acceptable_operation?,
        message: lambda { |p| "Operation must be :include, :exclude, or not passed (nil) " } },
      { query: :acceptable_precision?,
        message: lambda { |p| "Precision must be :exact or not passed (nil)" } },
      { query: :has_required_params?,
        message: lambda { |p| "Both :field and :value must be defined" } }
      ]
    end

    def acceptable_precision?(params)
      ALLOWED_PRECISION.include?(params.fetch(:precision, nil))
    end

    def acceptable_operation?(params)
      ALLOWED_OPERATION.include?(params.fetch(:operation, nil))
    end

    def has_required_params?(params)
      (REQUIRED_PARAMS - params.keys).empty?
    end
end
