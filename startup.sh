#!/bin/bash

bundle install
bundle exec foreman start -p ${PORT:-3035}
