#!/bin/bash -xe

export RAILS_ENV=test

git clean -fdx

bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment

govuk_setenv default bundle exec rake ci:setup:rspec default
