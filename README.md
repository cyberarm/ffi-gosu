[![Actions Status](https://github.com/cyberarm/ffi-gosu/workflows/Ruby%20CI/badge.svg?branch=master)](https://github.com/cyberarm/ffi-gosu/actions)
# Gosu - FFI Edition

This gem interfaces with the, currently under development, C API for the Gosu game library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ffi-gosu", require: "gosu"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ffi-gosu

## Usage

Where possibly this gem replicates the Ruby/Gosu gem, however, deprecated methods and constructors are not implemented.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyberarm/ffi-gosu.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
