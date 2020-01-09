# Steps to reproduce POC

## Setup Docker Container
Clone this gist and cd to its directory. Build the docker image containing all products to test. 

```shell
git clone git@gist.github.com:b8739a3cf4fea5591c8e041c35510b9f.git
cd b8739a3cf4fea5591c8e041c35510b9f
docker build -t hashi_inspec .
```

> Just using the public containers for the POC as they can be combined atm with little effort.

Open a seperate terminal window to run the container

```shell
# If this is your second run through
docker rm -f hashi_inspec
docker run -e VAULT_ADDR='http://127.0.0.1:8200' --name hashi_inspec -it hashi_inspec
```
This will open an interactive shell to the container to allow debugging. 

## Setup Inspec

### Optional: Install ruby via rbenv
This was tested under ruby 2.5.1 for backward compatiblity. You may skip these steps if your version is greater then that.However you may reference them if you have issues with macOS's system ruby. This guide assumes you have installed and configured [Home Brew](https://brew.sh/) as its beyond the scope of this document. 

```shell
brew install rbenv
rbenv install 2.5.1
rbenv shell 2.5.1
```

### Setup your ruby environment

If your system ruby or once you have configured rbenv use the following to install the required gems. 

```shell
gem install kramdown
gem install kramdown-parser-gfm
gem install inspec
gem install inspec-bin
```

If you have issues, copy the `Gemfile` from this post and run `bundle install` and use `bundle exec` to run `inspec`

> It might be worth looking into chefdk for portablity. 

### Generate an inspec report

Once you have the required gems you can execute the tests in this directory by copying `code_blocks.rb` to the `pages` directory of your local learn check out. 

To generate the html output:

```shell
cp code_blocks.rb ~/src/learn/pages
inspec exec code_blocks.rb -t docker://hashi_inspec --reporter html:tests.html
open tests.html
```

> Could be implemented as `Rakefile` in the future. 