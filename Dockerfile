FROM ruby:2.5.1

WORKDIR /

COPY Gemfile /
RUN bundle install

COPY . /

ENV CHEF_LICENSE accept-silent

RUN for profile in profiles/*/ ; \
      do bundle exec inspec vendor --overwrite $profile ; \
    done

ENTRYPOINT ["bundle", "exec", "inspec"]
