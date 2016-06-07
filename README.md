# Request Repeater

Simple [Ruby Gem]() or [Docker image](https://hub.docker.com/) to
execute GET request on an endpoint (Request Repeater).

This is usefull if you cannot do cron jobs in your application settup.

Just expose a certain route in your web application to execute the job
(or to schedule backround job) tell `request_repeeter` to trigger GET requests on it.

## Standalone Ruby gem

Add this line to your application's Gemfile:

```ruby
gem 'request_repeater'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install request_repeater

Or install it yourself as:

    $ gem install request_repeater


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

