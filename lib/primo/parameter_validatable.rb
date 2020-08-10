# frozen_string_literal: true

module Primo
  module ParameterValidatable
    # A mixin class designed to allow Validations of params
    # To use, include it in your class and then define an array of validators
    # that are hashes with a :query and :message keys.
    #  :query is a method you will pass the params to to run a single validations
    #  :message is a lmbda that retunrs a string telling the user what went wrong
    #    - the params will be passed to the message so you can
    #      reference the params in your error message
    #
    # EXAMPLE Usage #####################
    # include Primo::ParameterValidatable
    #
    # def validators
    #   [{ query: is_my_param_valid?,
    #      message: lambda { |params| "Param :q needs to be an integer, but you passed a #{params[:q].class}"  }
    #   }]
    # def is_my_param_valid?(params)
    #   params[:count].is_a? Integer
    #
    #######################################33


    def validate(params)
      validators.each do |validate|
        message = validate[:message][params]
        if !send(validate[:query], params)
          raise error_class.new(message)
        end
      end
    end

    # Use a local error class if the Class has a local error class
    # following the convention Primo::ClassName::ClassNameError
    # Otherwise use Primo::Search::SearchError
    def error_class
      error_class = Primo::Search::SearchError
      class_name = self.class.to_s.split("::").last
      class_error_name = class_name + "Error"
      if self.class.const_defined?(class_error_name)
        error_class = self.class.const_get(class_error_name)
      end
      error_class
    end
  end
end
