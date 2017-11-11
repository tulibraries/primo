# Primo [![Build Status](https://travis-ci.org/tulibraries/primo.svg?branch=master)](https://travis-ci.org/tulibraries/primo)

A client that wraps the Primo PNX REST API. The primary motivator for this
wrapper is to set up the authentication against the Primo PNX server in a
canonical and configurable way and to guard against changes and thus create
dependencies to known stable fields.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'primo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install primo

## Usage

### Configuration

You'll need to configure the Primo gem to ensure you query the appropriate data. To do so in a rails app, create config/initializers/gem.rb with :

```ruby
Primo.configure do |config|
  # You have to set te apikey 
  config.apikey     = 'EXAMPLE_PRIMO_API_KEY'
  # Primo gem defaults to querying Ex Libris's North American  Api servers. You can override that here.
  config.region   = "https://api-eu.hosted.exlibrisgroup.com

  # By dafault advance queries are combined using the :AND logical operator.
  config.operator = :AND
end
```

Now you can access those configuration attributes with `Primo.configuration.apikey`

### Making Requests

`Primo::Pnxs::get` takes a hash of attributes as defined in the [Primo PNX REST API](https://developers.exlibrisgroup.com/primo/apis/webservices/rest/pnxs) page and returns the API request result wrapped in an instance of the `Primo::Pnxs` class

```ruby
  # q is an instance of Primo::Pnxs::Query, see the next section for details.
  pnxs = Primo::Pnxs::get q: q

  pnxs.docs.first.date
  pnxs.info
  pnxs.facets
  # ...
```

#### Generating a Query object
```ruby
query = Primo::Pnxs::Query.new(
    precision: :exact,
    field: :facet_local23,
    value: "bar",
    operator: :AND)
```
This API wrapper validates the `query` object according the specifications documented in [the Ex Libris Api docs](https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch) for the `query` field.

#### Generating an advanced query with advanced operators
```ruby
query = Primo::Pnxs::Query.new(
    precision: :exact,
    field: :facet_local23,
    value: "bar",
    operator: :AND)

query.and( field: :title, precision: :contains, value: "foo")
query.or( field: :title, precision: :contains, value: "foo")
query.not( field: :title, precision: :contains, value: "foo")

q1 = field: :title, precision: :contains, value: "foo"
q1 = field: :title, precision: :contains, value: "bar"
Primo::Pnxs::Query::build([q1, q2])
```
This API wrapper validates the `query` object according the specifications documented in [the Ex Libris Api docs](https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch) for the `query` field.
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tulibraries/primo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
