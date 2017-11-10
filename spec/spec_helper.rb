# frozen_string_literal: true

require "bundler/setup"
require "primo"
require "pry"
require "pry-byebug"
require "binding_of_caller"
require "webmock"
require "vcr"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.default_cassette_options = {
    allow_playback_repeats: true,
    match_requests_on: [:method],
  }
end

def debugger
  Pry.start(binding.of_caller(1))
end

alias :debug :debugger
alias :bp :debugger
