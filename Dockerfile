# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This container is essentially a stack with inspec and kramdown.
# See Gemfile for gems and software versions used with this container.
FROM docker.mirror.hashicorp.services/ruby:2.5.1

WORKDIR /

COPY Gemfile /
RUN bundle install

COPY . /

ENV CHEF_LICENSE accept-silent

RUN for profile in ../profiles/*/ ; \
      do bundle exec inspec vendor --overwrite $profile ; \
    done

ENTRYPOINT ["bundle", "exec", "inspec"]
