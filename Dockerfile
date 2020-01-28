FROM ruby:2.5.1

WORKDIR /

COPY Gemfile /
RUN bundle install

COPY . /
ENV CHEF_LICENSE accept-silent
ENTRYPOINT ["bundle", "exec", "inspec"]
