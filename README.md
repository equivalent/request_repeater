# Request Repeater

Simple [Ruby Gem](https://rubygems.org/gems/request_repeater)
or [Docker image](https://hub.docker.com/r/equivalent/request_repeater/) to
execute GET request on an endpoint (Request Repeater).

This is useful if you cannot do cron jobs in your application setup.

Just expose a certain route in your web application to execute the job
(or to schedule background job) and tell `request_repeeter` to trigger GET requests on it.

**Application can be executed as**:

* :heavy_dollar_sign: [Standalone Ruby gem  application](https://github.com/equivalent/request_repeater#standalone-ruby-gem)
* :whale: [Docker image application](https://github.com/equivalent/request_repeater#docker-image-application)

## Standalone Ruby gem

[![Build Status](https://travis-ci.org/equivalent/request_repeater.svg?branch=master)](https://travis-ci.org/equivalent/request_repeater)
[![Code Climate](https://codeclimate.com/github/equivalent/request_repeater/badges/gpa.svg)](https://codeclimate.com/github/equivalent/request_repeater)
[![Test Coverage](https://codeclimate.com/github/equivalent/request_repeater/badges/coverage.svg)](https://codeclimate.com/github/equivalent/request_repeater/coverage)

#### Instalation

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

#### Usage

**Single endpoint**

Pass enviroment variable `URL` with location

```
# every second send request to http://localhost:3000/execute-something.html
$ URL=http://localhost:3000/execute-something.html bundle exec request_repeater

# ...or if you didn't use Bundler
$ URL=http://localhost:3000/execute-something.html request_repeater
```

Default timeout is 1000ms (1 second), if you need different timeout pass
`SLEEPFOR` env variable:

```
# every two seconds send request to https://localhost:3000/maintenance?token=12345
$ URL=https://localhost:3000/maintenance?token=12345 SLEEPFOR=2000 bundle exec request_repeater
```

For authentication we recommend just to pass token as a query param,
like: `/maintenance?token=12345`

**Multiple endpoints**

You need to pass `URLS` env variable with json in format:

```json
{
  "urls": [
    {"url":"http://myserver/some-endpoint", "sleep":4000},
    {"url":"http://myserver/another-endpoint", "sleep":1200},
    {"url":"http://myserver/third-endpoint", "sleep":72000}
  ]
}
```

example:

```
$ URLS='{"urls": [{"url":"http://localhost/some-endpoint", "sleep":1200}, {"url":"http://localhost/another-endpoint","sleep":3000}]}' bundle exec request_repeater
```

> `URL` and `SLEEPFOR` env variables are ignored when you provide `URLS` env variable

## Docker Image Application

![Docker Image Stats](http://dockeri.co/image/equivalent/request_repeater)
[![](https://imagelayers.io/badge/equivalent/request_repeater:latest.svg)](https://imagelayers.io/?images=equivalent/request_repeater:latest 'Get your own badge on imagelayers.io')

#### Usage

```bash
$ docker pull equivalent/request_repeater
```

**Single Endpoint**

Specify `URL` env variable


```bash
$ docker run -e "URL=http://www.my-app.dot/execute-something.html" equivalent/request_repeater
```

Default timeout is 1000ms (1 second), if you need different timeout pass
`SLEEPFOR` env variable:

```bash
# 2 second timeout
$ docker run -e "SLEEPFOR=2000" -e "URL=http://www.my-app.dot/execute-something.html" equivalent/request_repeater
```

To execute on localhost of image host:

```bash
$ docker run -e "SLEEPFOR=2000" -e "URL=http://localhost:3000/execute-something.html" --net="host" equivalent/request_repeater
```

You want authentication ? How about passing token param:

```bash
$ docker run -e "URL=https://www.my-app.dot/execute-something.html?token=1234556"  equivalent/request_repeater
```

**docker-compose.yml example**

```yml
---
version: '2'
services:
  nginx:
    image: quay.io/myorg/my-nginx-image
    ports:
      - "80:80"
  request_repeater:
    image: 'equivalent/request_repeater'
    links:
      - nginx:nginx
    environment:
      URL: 'http://nginx/some-endpoint'
      SLEEPFOR: 7200
```


**AWS Elastic Beanstalk Dockerrun.aws.json example**

```json
{
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "........",
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80
        }
      ],
    },
    {
      "name": "request_repeater",
      "image": "equivalent/request_repeater",
      "essential": true,
      "memory": 150,
      "links": [ "nginx" ],
      "environment": [
        {
          "name": "URL",
          "value": "http://nginx/some-endpoint"
        }
      ]
    }
  ]
}
```

**Multiple endpoints**

You need to pass `URLS` env variable with JSON in format:

```json
{
  "urls": [
    {"url":"http://myserver/some-endpoint", "sleep":4000},
    {"url":"http://myserver/another-endpoint", "sleep":1200},
    {"url":"http://myserver/third-endpoint", "sleep":72000}
  ]
}
```

```bash
$ docker run -e 'URLS={"urls": [{"url":"http://localhost/some-endpoint", "sleep":1200}, {"url":"http://localhost/another-endpoint","sleep":3000}]}' --net="host" equivalent/request_repeater
```

> `URL` and `SLEEPFOR` env variables are ignored when you provide `URLS` env variable

#### Docker Composer example

*docker-compose.yml*:

```yml
---
version: '2'
services:
  nginx:
    image: quay.io/myorg/my-nginx-image
    ports:
      - "80:80"
  request_repeater:
    image: 'equivalent/request_repeater'
    links:
      - nginx:nginx
    environment:
      URLS: '{"urls": [{"url":"http://nginx/some-endpoint", "sleep":1200},
{"url":"http://nginx/another-endpoint","sleep":7200}]}'
```

#### AWS Elastic Beanstalk Dockerrun.aws.json example usage

*Dockerrun.aws.json*:

```json
{
  "containerDefinitions": [
    {
      "name": "nginx",
      "image": "........",
      "portMappings": [
        {
          "hostPort": 80,
          "containerPort": 80
        }
      ],
    },
    {
      "name": "request_repeater",
      "image": "equivalent/request_repeater",
      "essential": true,
      "memory": 150,
      "links": [ "nginx" ],
      "environment": [
        {
          "name": "URLS",
          "value":"{\"urls\":[{\"url\":\"http://nginx/some-endpoint\",\"sleep\":1300},{\"url\":\"http://nginx/other-endpoint\",\"sleep\":1200000}]}"

        }
      ]
    }
  ]
}
```

#### Kill the container

```bash
$ docker kill $(docker ps | grep request_repeater | awk "{print \$1}")

# sudo version
$ sudo docker kill $(sudo docker ps | grep request_repeater | awk "{print \$1}")
```

## Minimum Sleeptime

In order to avoid docker container / gem to use all CPU resources  there is a minimum sleep
time implementend set to `500 miliseconds`. If you need to use this
image without this limit provide one more extra enviroment variable `MINIMUMSLEEP`:

```
$ URL=https://www.my-app.dot/execute-something.html SLEEPFOR=100 MINIMUMSLEEP=0 bundle exec request_repeater

$ docker run -e "SLEEPFOR=300" -e 'MINIMUMSLEEP=300' -e "URL=http://www.my-app.dot/execute-something.html" equivalent/request_repeater # 300 ms

$ docker run -e "SLEEPFOR=0" -e 'MINIMUMSLEEP=0' -e "URL=http://www.my-app.dot/execute-something.html" equivalent/request_repeater # no limit
```

## Alternatives

This Ruby Gem (and Docker image) is attempt to rewrite [little_bastard golang Docker image](https://github.com/equivalent/little_bastard)
which has a issue with memory leak causing eventually docker container to
restart after several hours of activity, but can handle more requests
per second. If you need something that does more requests per second
(e.g.: testing your app against DDOS attack)
then [Little Bastard](https://hub.docker.com/r/equivalent/request_repeater/)
image is better for you.

`equivalent/request_repeater`  aims to provide stable flow of
repeating requests without crushing over time.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

