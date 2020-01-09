# Steps to reproduce POC

## Setup Docker Container
Copy the `Dockerfile` and all `*.tf|tfvars` to a directory. Build the named docker container

```shell
docker build -t hashi_inspec .
```

Open a seperate window to run the containers

```shell
docker rm -f hashi_inspec
docker run -e VAULT_ADDR='http://127.0.0.1:8200' --name hashi_inspec -it hashi_inspec
```
This will open an interactive shell to the container to allow debuging. 

## Setup Inspec

### Optional: Install ruby via rbenv
This was tested under ruby 2.5.1 for backward compatiblity. You may skip these steps if your version is great then that or reference them if you have issues with macOS's system ruby. This guide assumes you have installed and configured [Home Brew](https://brew.sh/) as its beyond the scope of this document. 

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
