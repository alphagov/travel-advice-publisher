#!/bin/bash -xe

export RAILS_ENV=test

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

export GOVUK_APP_DOMAIN=dev.gov.uk

bundle exec rake ci:setup:rspec default
