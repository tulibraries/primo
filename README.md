# Primo [![Build Status](https://travis-ci.org/tulibraries/primo.svg?branch=main)](https://travis-ci.org/tulibraries/primo)

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
You'll need to configure the Primo gem to ensure you query the appropriate data. To do so in a rails app, create config/initializers/primo.rb with :

```ruby
Primo.configure do |config|
  # An API Key is required for the hosted environment.
  config.apikey     = 'EXAMPLE_PRIMO_API_KEY'

  # An Institutation value is required for the local environment.
  config.inst     = 'EXAMPLE_INSTITUTION'

  # Primo gem defaults to querying Ex Libris's North American  Api servers. You can override that here.
  config.region   = "https://api-eu.hosted.exlibrisgroup.com

  # By dafault advance queries are combined using the :AND logical operator.
  config.operator = :AND

  # By default queries use the :title field
  config.field = :sub

  # By default queries use the :contains precision
  config.precision = :exact

  # By default by id queries use the :L context
  config.context = :PC

  # By default the environment is assumed to be :hosted
  config.environment = :local

  # By default vid will be nil
  config.vid = "MYVID"

  # By default scope will be nil
  config.scope = "pci_scope"

  # By default the pcAvailability is set to false
  config.pcavailability = false

  # By default enable_loggagle is set to false
  config.enable_loggagle = false

  # By default timeout is set to 5 seconds
  config.timeout = 10

  # By default we validate parametters.
  config.validate_parameters = false
end
```
Now you can access those configuration attributes with `Primo.configuration.apikey`

### Making Requests

#### Making simple requests
Simple requests are easy:

* Pass a string and you will query titles containing the string (the default field and precison used are configurable)

```
Primo.find("otter")
```

or

```
Primo.find_by_id("foobar")
```

#### Making More advanced requests
* `Primo.find_by_id` accepts a hash in order to pass in context or other attributes as defined in the [Primo PNX REST API](https://developers.exlibrisgroup.com/primo/apis/webservices/rest/pnxs) docs.

```ruby
Primo.find_by_id(id: "foo", context: :PC)
```

* `Primo.find` also accepts a hash of attributes as defined in the [Primo PNX REST API](https://developers.exlibrisgroup.com/primo/apis/webservices/rest/pnxs) page and returns the API request result wrapped in an instance of the `Primo::Search` class.

`q` is the only required parameter for this hash and it is either composed of a `Primo::Search::Query` object, or a hash that is converted into a `Primo::Search::Query` object.

```ruby
  # q is an instance of Primo::Search::Query, see the next section for details.
  # defaults for :field and :precision are added if not included in the hash.
  response = Primo.find q: { field: sub:, precision: :contains, value: "goats" }

  response.docs.first.date
  response.info
  response.facets
  # ...
```

#### (Advanced) Generating a Query object
```ruby
query = Primo::Search::Query.new(
    precision: :exact,
    field: :facet_local23,
    value: "bar",
    operator: :AND)
```
This API wrapper validates the `query` object according the specifications documented in [the Ex Libris Api docs](https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch) for the `query` field.

#### (Advanced) Adding Facets to a query

Once you have your base query, you can add facet queries to limit the search

```ruby
query = Primo::Search::Query.new(...)

query.facet(
  { field: "creator",
    value: "Williams, John",
    })

response = Primo.find(q: query)    
```

##### Exclude Facets

By default, facets are *include facets*, so that records returned should include the value
in the field. You can also set *exclude facets* for results that should not contain a value
in a given field, by setting the `operator` parameter to `:exclude`

```ruby
query.facet(
  { field: "creator",
    value: "Williams, John",
    operator: :exclude
    })

```
##### Multiple Facets

You can also call facet multiple times to apply multiple facets
```ruby
query.facet({
  field: "creator",
  value: "Williams, John",
}).facet({
    field: "format",
    value: "Book"
    })
```

##### Date Range Facet

You can also add a date range facet (inclusive or execlusive)

```ruby
query.date_range_facet({
  min: 1973, # defauls to 0
  max: 2012, # defaults to 9999
  operator: :exclude, #defaults inclusive
}).facet({
    field: "format",
    value: "Book"
    })
```


#### Generating advanced queries with advanced operators
```ruby
query = Primo::Search::Query.new(
    precision: :exact,
    field: :facet_local23,
    value: "bar",
    operator: :AND)

query.and( field: :title, precision: :contains, value: "foo")
query.or( field: :title, precision: :contains, value: "foo")
query.not( field: :title, precision: :contains, value: "foo")
```

#### Generating an advanced query with the `#build` method:
```ruby
q1 = field: :title, precision: :contains, value: "foo"
q1 = field: :title, precision: :contains, value: "bar"
Primo::Search::Query::build([q1, q2])
```

This API wrapper validates the `query` object according the specifications documented in [the Ex Libris Api docs](https://developers.exlibrisgroup.com/primo/apis/webservices/xservices/search/briefsearch) for the `query` field.

### Logging
This gem exposes a loggable interface to responses.  Thus a response will respond to `loggable` and return a hash with state values that may be of use to log.

As a bonus, when we enable this feature using the `enable_loggable` configuration, error messages will contain the loggable values and be formatted as JSON.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/tulibraries/primo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
