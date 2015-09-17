#!/bin/bash

export REPO_NAME="alphagov/govuk-content-schemas"
export CONTEXT_MESSAGE="Verify travel-advice-publisher against content schemas"
export TEST_TASK="spec:schema"

#exec ./jenkins.sh

set -e

FOO="/bin/true"

echo ${BAR:-$FOO}
if ${BAR:-$FOO}; then
  echo "true"
else
  echo "false"
fi
