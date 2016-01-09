# Baboon - simple rails deployment.
![cardinal](https://alexweb.s3.amazonaws.com/baboon.png)

A simple and light weight deployment library for a ruby on rails application 3.0+. No symlinks, no releases, just git and your application. 

<!--[![Build Status](https://secure.travis-ci.org/amanelis/baboon.png)](http://travis-ci.org/amanelis/baboon)-->
<!--[![Dependency Status](https://gemnasium.com/amanelis/baboon.svg)](https://gemnasium.com/amanelis/baboon)-->
<!--[![Code Climate](https://codeclimate.com/github/amanelis/baboon.png)](https://codeclimate.com/github/amanelis/baboon)-->
<!--[![Coverage Status](https://coveralls.io/repos/amanelis/baboon/badge.png?branch=master)](https://coveralls.io/r/amanelis/baboon)-->


# How it works
Baboon is simple. You provide your server addresses, environments, path, repository, username and Baboon does the rest. By running a simple `baboon deploy {env}` it will do all neccessary operations you intend for it to do on a full deploy to a production staging or development server. All you need is a working rails application on a server with a git repository.

---
# Install
This must be installed under a current rails application. We recommend vendoring or installing through bundler.

	$ gem install baboon

---
# Configure

In your Gemfile, then `bundle install`.

```rb
gem 'baboon'
```
	
Now that the gem is installed, run the config generator

	$ rails g baboon:install

This will build a file into your application under `config/baboon.yml`. Open this file and start editing. Here is an example of the main configuration options:
```yaml
baboon:
  # Give you application a descriptive name, has no effect on the actual
  # running path or location of your application. Can be different then
  # what is stored in your scm.
  application:  'Vacuum HQ'

  # For now, Baboon will determine what scm the remote code is stored 
  # in based on the scm path. 
  repository:   'git@github.com:amanelis/vacuum.git'

  # Pass multiple environments in this section. Each environment you 
  # specify then becomes part of the deploy command: baboon deploy  
  # {environment}. Below, we have defined two envs of staging and 
  # production. Add more as needed.
  environments:
    # Name each environment to your own standard. Baboon, will use the 
    # settings defined after the env to to the deploy. This environment 
    # is named 'staging' -> baboon deploy staging
    staging:
      # This is the branch from your scm that Baboon will pull and merge 
      # code from. The repository is defined in the root node of this 
      # configuration file.
      branch: 'staging'

      # Callbacks, pre and post deploy. Specify any command you want 
      # executed pre and post in blocks below as array elements.
      callbacks:
        # These will be run before the code fetch and server restart.
        before_deploy:
          - '/etc/init.d/my_service stop'
          - 'ruby clean_and_free_memory.rb'

        # These will be run after the code fetch and server restart.
        after_deploy:
          - '/etc/init.d/my_service start'
          - 'ruby warm_cache.rb'

      # This is the path on the server where the root of the 
      # application is stored, not where /public is in terms of a rails
      # setup.
      deploy_path: '/home/rails/vacuum'
 
      # This is the user that baboon will use for SSH authentication
      # into the servers that are defined here. 
      deploy_user: 'rails'

      # Rails environment that Baboon will run all rake/bundler commands
      # with.
      rails_env: 'staging'

      # Custom server restart_command. If your server happens to not respond
      # `touch tmp/restart.txt` - specify your restart command. Otherwise
      # default Baboon will try and touch the restart.txt file.
      restart_command: '/etc/init.d/appache2 restart'

      # These are the host machines that baboon will ssh into on each
      # deploy. They can be defined as an ip address or a host name
      servers:
        - '127.0.0.1'
        - '127.0.0.2'
          
    # You can define as many different environments as needed. 
    production:
      branch: 'master'
      callbacks:
        before_deploy:
          - '/etc/init.d/my_service stop'
        after_deploy:
          - '/etc/init.d/my_service start'
      deploy_path: '/home/rails/vacuum'
      deploy_user: 'rails'
      rails_env: 'production'
      restart_command: '/etc/init.d/apache2 restart'
      servers:
        - '10.0.0.1'
        - '10.0.0.2'
        - '10.0.0.3'
        - 'production.node1.east.com'
```	
	
These must be properly filled out so baboon can properly make deploys. One single environment always has a `branch` that baboon will know where to pull the deployable code from. It will assume the `repository` from the root node. For the environment, baboon will need to know what user to login as via the `deploy_user` and where to cd to via the `deploy_path`. Once it knows the location of the app, baboon will need to know what env to run as, hence the `rails_env` setting. The last option is the `servers` collection. Fill as many servers as you would like and baboon will deploy to all for the given env. Asynchronous is the next option we would like to add.

---
# Commands
Once everything is setup you can run `baboon` to see available commands. Start by seeing if your configuration was properly generated by running the following command:

	$ baboon configuration
	
For now, lets assume you have everything in your config correct and you are deploying to production, run the following command to do a deploy:

	$ baboon deploy production
	
Any other deploy to a different env that you specify in your config file can be done as follows:

	$ baboon deploy {environment}
	
To view the available servers you have setup in your config file, the following command will tell you which servers are set to be deploy to:

	$ baboon servers production
	
Thats it? Yeah, thats it! You should see your bundle installing and Baboon running all tasks. Custom tasks coming soon.

The next commands that will be realeased with future versions of baboon are:


  	baboon setup    		# no manually editing of configuration file
	baboon check 		    # checks the server and config file for proper configuration
	baboon migrate 		  	# runs pending migrations
	baboon restart 		  	# restarts your server
	baboon rollback 	  	# rolls back your to your previous commit, info in ./log/baboon.log
	baboon rake 			# run custom rake tasks on server
	baboon execute 			# run a single command on the server
	baboon shell	 		# open a remote shell with the config user


---
## Dependencies
#### Install dependencies using bundler  
    $ bundle
  
#### Run rSpec  
    $ rspec spec/

## Issues
  None.

## Changelog
#### 1.0.0
Intial setup of the CLI and basic deploys are working.

#### 1.0.5
Multiple server deployments now work.

#### 1.0.6
Changed the order of bundle installing on Rails package. Wrote tests for CLI.

#### 1.0.9
Removed ruby configuration and added configuration by `config/baboon.yml`. More environments.

## Thanks
I'd like to thank Enrique Ruiz Davila for making the beautiful [Baboon](http://www.behance.net/davila) image. 

## How to contribute
 
* Fork the project.
* Make your feature addition or bug fix, push to a named branch.
* Add a test for any code committed.
* Send a pull request.

Copyright (c) 2011 [Alex Manelis](http://twitter.com/amanelis). 
