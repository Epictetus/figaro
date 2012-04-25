# Figaro [![Build Status](https://secure.travis-ci.org/laserlemon/figaro.png)](http://travis-ci.org/laserlemon/figaro) [![Dependency Status](https://gemnasium.com/laserlemon/figaro.png)](https://gemnasium.com/laserlemon/figaro)

Simple Rails app configuration

## What is this?

Figaro is for configuring Rails 3 apps, especially open source Rails apps.

Open sourcing a Rails app can be a little tricky when it comes to sensitive configuration information like [Pusher](http://pusher.com/) or [Stripe](https://stripe.com/) credentials. You don't want to check private credentials into the repo but what other choice is there?

Figaro provides a clean and simple way to configure your app and keep the private stuff… _private_.

## How does it work?

There are a few similar solutions out there, and a lot of homegrown attempts. Most namespace your configuration under a `Config` (or similar) namespace. That's fine, but there's already a place to describe the application environment… `ENV`!

`ENV` is a collection of simple string key/value pairs and its perfect for application configuration.

**BONUS**: This is exactly how apps on [Heroku](http://www.heroku.com/) are configured. So if you configure your with Figaro, you're ready to deploy on Heroku.

## Give me an example.

Okay. First, add Figaro to your Gemfile and bundle:

```ruby
gem "figaro"
```

Next up, install Figaro:

```bash
$ rails generate figaro:install
```

This generates a commented-out `config/application.yml` file and ignores it in your `.gitignore`. Add your own configuration to this file and you're done!

Your configuration will be available as key/value pairs in `ENV`. For example, here's `config/initializers/pusher.rb`:

```ruby
Pusher.app_id = ENV["PUSHER_APP_ID"]
Pusher.key    = ENV["PUSHER_KEY"]
Pusher.secret = ENV["PUSHER_SECRET"]
```

If your app requires Rails-environment-specific configuration, you can also namespace your configuration under a key representing `Rails.env` in `application.yml`.

```yaml
HELLO: world
development:
  HELLO: developers
production:
  HELLO: users
```

In this case, `ENV["HELLO"]` will produce `"developers"` in development, `"users"` in production and `"world"` otherwise.

## How does it work with Heroku?

Heroku's beautifully simple application configuration was the [inspiration](http://laserlemon.com/blog/2011/03/08/heroku-friendly-application-configuration/) for Figaro.

Typically, to configure your application `ENV` on Heroku, you would do the following from the command line using the `heroku` gem:

```bash
$ heroku config:add PUSHER_APP_ID=8926
$ heroku config:add PUSHER_KEY=0463644d89a340ff1132
$ heroku config:add PUSHER_SECRET=0eadfd9847769f94367b
$ heroku config:add STRIPE_API_KEY=jHXKPPE0dUW84xJNYzn6CdWM2JfrCbPE
$ heroku config:add STRIPE_PUBLIC_KEY=pk_HHtUKJwlN7USCT6nE5jiXgoduiNl3
```

But Figaro provides a rake task to do just that! Just run:

```bash
$ rake figaro:heroku
```

Optionally, you can pass in the name of the Heroku app:

```bash
$ rake figaro:heroku[my-awesome-app]
```

### What if I'm not using Heroku?

No problem. Just add `config/application.yml` to your production app on the server.

## Give me Travis or give me death!

Okay, okay. Travis allows you to add an `env` configuration to your `.travis.yml` file, which is then included in `ENV` during your build.

```yaml
language: ruby
env: FOO=bar HELLO=world
```

That's pretty handy. The problem is that `.travis.yml` is checked into your repo, so for open source apps, this puts your private configurations out in the wild.

Fortunately, Travis recently shipped [secure env configuration](https://github.com/travis-ci/travis-core/pull/45). The process of manually encrypting your `env` is pretty convoluted, but don't worry… **Figaro does it for you!**

If your app is already on Travis and using Figaro, just:

```bash
$ rake figaro:travis
```

This wraps up your Figaro configuration, encrypts it and adds it to your `.travis.yml` file:

```yaml
language: ruby
env: {secure: ec7ij5JLi8t3w5sq1ymG/xo6k0XYAfqENw8UQjT44BwsmJrlZZr75pLW/IvfJXn1JpthRuQsdO6ba0aozYIDmswwsY/LbqYutHvEaIZSy9Eo5VISGeZdbhRSe9fIXgXKNnWMBLDez81cGhdumMs0LkwrQiQr5nk06yt8gndr2Dg=}
```

If you need to include additional, Travis-specific configuration variables, you can do so right in the rake task:

```bash
$ rake figaro:travis[FOO=baz CI=true]
```

**REASSURANCE**: If you're still worried about the security of your encrypted configuration, don't be. Each project on Travis gets a secure public/private key pair. The private key is never exposed outside of Travis and the public key is… [_public_](http://travis-ci.org/laserlemon/figaro.json). Figaro encrypts using the public key and only Travis can decrypt using the private key.

## This sucks. How can I make it better?

1. Fork it.
2. Make it better.
3. Send me a pull request.

## Does Figaro have a mascot?

Why, yes!

[![Figaro](http://images2.wikia.nocookie.net/__cb20100628192722/disney/images/5/53/Pinocchio-pinocchio-4947890-960-720.jpg "Figaro's mascot: Figaro")](http://en.wikipedia.org/wiki/Figaro_(Disney\))
