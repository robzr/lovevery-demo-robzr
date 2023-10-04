ARG APP_DIR=app
ARG BASE_IMAGE=ruby:3.2
ARG PLATFORMS
ARG RAILS_VERSION="'~> 7.0', '>= 7.0.8'"


FROM ${BASE_IMAGE} AS image-base
RUN mkdir -p /opt/app
WORKDIR /opt/app


FROM image-base as image-rails
ARG RAILS_VERSION
RUN echo "source \"https://rubygems.org\"\n" > Gemfile \
    && echo "gem 'rails', ${RAILS_VERSION}" >> Gemfile \
    && bundle install
ENTRYPOINT ["rails"]
CMD ["--help"]


FROM image-base as image-bundled
ARG APP_DIR
ARG PLATFORMS
ENV BUNDLE_FROZEN=true
COPY "${APP_DIR}/Gemfile" "${APP_DIR}/Gemfile.lock" .
RUN for platform in ${PLATFORMS} ; do \
      BUNDLE_FROZEN=false bundle lock --add-platform "$platform" ; \
    done
RUN bundle install
ENTRYPOINT ["rails"]
CMD ["--help"]


FROM image-bundled as image
ARG APP_DIR
COPY "${APP_DIR}" .
ENTRYPOINT ["./bin/rails"]
CMD ["--help"]
