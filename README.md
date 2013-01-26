# Baboon
![cardinal](https://alexweb.s3.amazonaws.com/baboon.jpeg)

[![Build Status](https://secure.travis-ci.org/amanelis/baboon.png)](http://travis-ci.org/amanelis/baboon)
[![Dependency Status](https://gemnasium.com/amanelis/baboon.png)](https://gemnasium.com/amanelis/baboon)

A simple and light weight deployment library for a ruby on rails application 3.0+.


# How it works
Baboon is simple. You provide your server addresses, environments, path, repository and a username. Baboon does the rest. By running a simple `baboon deploy {env}` it will do all neccessary operations you intend for it to do on a full deploy to a production staging or development server. All you need setup is a working rails application on a server and/or have your keys setup so you don't have to type your password in. Baboon also has rollbacks which just do a git reset {prev commit}. Later there will be better support for this. Future support for Baboon will be CI. 


---
# Install
This must be installed under a current rails application. We recommend vendoring or installing through bundler.

	gem install baboon

---
# Configure

In your Gemfile, then `bundle install`.

	group :development do
	  gem 'baboon'
	end
	
Now that the gem is installed, run the config generator

	rails g baboon:install

This will build a file into your application under `config/initializers/baboon.rb`. Open this file and start editing. Here is an example of the 8 configuration options:

	Baboon.configure do |config|
  	  config.application  = 'Vacuum HQ'
	  config.repository   = 'git@github.com:amanelis/vacuum.git'
	  config.releases     = 5
	  config.deploy_path  = '/home/rails/vacuum'
	  config.deploy_user  = :rails
	  config.branch       = :master
	  config.rails_env    = :production
	  config.servers      = ['server_1', 'server_2']
	end

---
# Commands
Once everything is setup you can run `baboon` to see availabe tasks. Start by seeing if your configuration was properlly generated.

	baboon configuration
	
Once you see and verify your Baboon.configuration you can now go ahead and test a deploy. For now, lets assume you have everything in your config correct and you are deploying to production:

	baboon deploy
	
Thats it? Yeah, thats it! You should see your bundle installing and Baboon running all tasks. Custom tasks coming soon.

---
# CLI

This is coming very soon…


---
## Dependencies
#### Install dependencies using bundler  
    $ bundle
  
#### Run rSpec  
    $ rspec spec/

## Issues
  None.

## How to contribute
 
* Fork the project.
* Make your feature addition or bug fix, push to a named branch.
* Add a test for any code committed.
* Send a pull request.

Copyright (c) 2011 [Alex Manelis](http://twitter.com/amanelis). 