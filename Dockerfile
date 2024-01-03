ARG ruby_version=3.2.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version


FROM $builder_image AS builder

WORKDIR $APP_HOME
COPY Gemfile* .ruby-version ./
RUN bundle install
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases ./.yarn/releases
RUN yarn workspaces focus --all --production
COPY . .
RUN bootsnap precompile --gemfile .
RUN rails assets:precompile && rm -fr log node_modules

FROM $base_image
RUN install_packages imagemagick

ENV GOVUK_APP_NAME=travel-advice-publisher

WORKDIR $APP_HOME
COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=builder $BOOTSNAP_CACHE_DIR $BOOTSNAP_CACHE_DIR
COPY --from=builder $APP_HOME .

USER app
CMD ["puma"]
