# frozen_string_literal: true

require "bundler/setup"
require "primo"
require "pry"
require "pry-byebug"
require "binding_of_caller"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def debugger
  Pry.start(binding.of_caller(1))
end

alias :debug :debugger
alias :bp :debugger
